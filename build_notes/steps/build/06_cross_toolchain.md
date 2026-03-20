# Cross-Toolchain — ft_linux

A cross-toolchain is a compiler+linker+libc combo that runs on your **host** but produces binaries for the **target** (`$LFS_TGT`). You need it because the final system can't build itself from nothing.

Build order is strict: each step depends on the previous one.

---

## Quick run (automated)

```bash
# verify the environment first
bash scripts/02_build/compiler-toolchain/00_check_env.sh

# build all 5 steps
bash scripts/02_build/01_run_compiler_toolchain.sh

# resume from step N if a step failed
bash scripts/02_build/01_run_compiler_toolchain.sh <N>
```

Individual scripts (run in order):
- [00_check_env.sh](../../scripts/02_build/compiler-toolchain/00_check_env.sh)
- [01_binutils.sh](../../scripts/02_build/compiler-toolchain/01_binutils.sh)
- [02_gcc.sh](../../scripts/02_build/compiler-toolchain/02_gcc.sh)
- [03_linux_API.sh](../../scripts/02_build/compiler-toolchain/03_linux_API.sh)
- [04_glibc.sh](../../scripts/02_build/compiler-toolchain/04_glibc.sh)
- [05_libstdc.sh](../../scripts/02_build/compiler-toolchain/05_libstdc.sh)

---

## Manual run (step by step)

Run everything as the `lfs` user with the environment sourced:
```bash
sudo su - lfs          # switch to lfs user
source ~/.bash_profile  # loads LFS, LFS_TGT, PATH, MAKEFLAGS
```

### Step 0 — Check environment

Verifies user, env vars, mounts, disk space, source tarballs, and host tools.

```bash
bash scripts/02_build/compiler-toolchain/00_check_env.sh
```

All checks must pass before continuing.

---

### Step 1 — Binutils (Pass 1)

Builds the cross-assembler (`as`) and cross-linker (`ld`). GCC requires these to exist before it can be configured.

```bash
cd $LFS/sources
tar -xf binutils-*.tar.xz
cd binutils-*/

mkdir -v build && cd build

../configure          \
    --prefix=$LFS/tools \
    --with-sysroot=$LFS \
    --target=$LFS_TGT   \
    --disable-nls       \
    --enable-gprofng=no \
    --disable-werror    \
    --enable-new-dtags  \
    --enable-default-hash-style=gnu

make
make install

cd $LFS/sources
rm -rf binutils-*/
```

---

### Step 2 — GCC (Pass 1)

Builds a minimal cross-compiler (C and C++ only, no shared libs, no threads). GMP, MPFR, and MPC are bundled inside the GCC source tree so the host doesn't need them installed.

```bash
cd $LFS/sources
tar -xf gcc-*.tar.xz
cd gcc-*/

# bundle required math libraries
tar -xf ../mpfr-*.tar.xz && mv -v mpfr-* mpfr
tar -xf ../gmp-*.tar.xz  && mv -v gmp-*  gmp
tar -xf ../mpc-*.tar.xz  && mv -v mpc-*  mpc

# x86_64 only: redirect 64-bit lib dir from lib64 → lib
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
esac

mkdir -v build && cd build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.40 \
    --with-sysroot=$LFS       \
    --with-newlib              \
    --without-headers          \
    --enable-default-pie       \
    --enable-default-ssp       \
    --disable-nls              \
    --disable-shared           \
    --disable-multilib         \
    --disable-threads          \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libssp           \
    --disable-libvtv           \
    --disable-libstdcxx        \
    --enable-languages=c,c++

## for erorr 
#checking build system type... config.guess: cannot create a temporary directory in /tmp
#configure: error: cannot guess build type; you must specify one
#try as root: `chmod 1777 /tmp`
#else add the env var to the lfs shell: `export TMPDIR=$LFS/sources`

make
#../../gcc/expmed.cc:1864:45: warning: '*(unsigned int*)((char*)&imode + offsetof(scalar_int_mode, scalar_int_mode::m_mode))' may be used uninitialized in this function [-Wmaybe-uninitialized]
# 1864 |       rtx sub = extract_bit_field_as_subreg (mode1, op0, imode,
#      |                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~
# 1865 |                                              bitsize, bitnum);
#      |                                              ~~~~~~~~~~~~~~~~
#../../gcc/gimple-fold.cc:7764:20: warning: 'xor_cmp_op' may be used uninitialized in this function [-Wmaybe-uninitialized]
# 7764 |       *pxor_cmp_op = xor_cmp_op;
#      |       ~~~~~~~~~~~~~^~~~~~~~~~~~
#../../gcc/gimple-range-gori.cc:318:19: warning: format not a string literal and no format arguments [-Wformat-security]
#  318 |           fprintf (f, prefix);
#      |           ~~~~~~~~^~~~~~~~~~~
make install

# create the minimal limits.h that Glibc needs during its configure
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    "$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h"

cd $LFS/sources
rm -rf gcc-*/
```

---

### Step 3 — Linux API Headers

Exposes the kernel's syscall interface to Glibc. Only `.h` files are kept — generated object files are discarded.

```bash
mkdir -pv $LFS/usr/include

cd $LFS/sources
tar -xf linux-*.tar.xz
cd linux-*/

make mrproper   # ensure no stale build artefacts from the tarball

make headers
find usr/include -type f ! -name '*.h' -delete

cp -rv usr/include $LFS/usr/

cd $LFS/sources
rm -rf linux-*/
```

---

### Step 4 — Glibc

The GNU C Library — the most critical step. After installation a sanity check confirms the ELF interpreter path is inside `$LFS`, not your host system. **If the check fails, stop and do not continue.**

```bash
cd $LFS/sources
tar -xf glibc-*.tar.xz
cd glibc-*/

# x86_64 only: dynamic linker compatibility symlinks
case $(uname -m) in
    x86_64)
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac

mkdir -v build && cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
    --prefix=/usr                        \
    --host=$LFS_TGT                      \
    --build=$(../scripts/config.guess)   \
    --enable-kernel=4.19                 \
    --with-headers=$LFS/usr/include      \
    --disable-nscd                       \
    libc_cv_slibdir=/usr/lib

make
make DESTDIR=$LFS install

# fix ldd's hardcoded /usr prefix
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# ── Sanity check ──────────────────────────────────────────────────────────────
# The cross-compiler must request /lib64/ld-linux-x86-64.so.2 as its
# ELF interpreter. Any other path means the toolchain is pointing at the
# host and is broken.
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep "program interpreter"
rm -f a.out
# Expected: [/lib64/ld-linux-x86-64.so.2]
# If you see /lib/x86_64-linux-gnu/... or any host path → toolchain is broken.

cd $LFS/sources
rm -rf glibc-*/
```

---

### Step 5 — Libstdc++ (Pass 1)

The C++ standard library, extracted from the GCC source tree and cross-compiled into `$LFS`. Needed so that temporary C++ tools in the next phase can link against it.

```bash
cd $LFS/sources
tar -xf gcc-*.tar.xz
cd gcc-*/

mkdir -v build && cd build

../libstdc++-v3/configure        \
    --host=$LFS_TGT              \
    --build=$(../config.guess)   \
    --prefix=/usr                \
    --disable-multilib           \
    --disable-nls                \
    --disable-libstdcxx-pch      \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/$(cat ../gcc/BASE-VER)

make
make DESTDIR=$LFS install

# .la files are only used by libtool and cause linker problems if left here
find $LFS/usr/lib -name 'libstdc++*.la' -o -name 'libsupc++.la' | xargs rm -fv

cd $LFS/sources
rm -rf gcc-*/
```

---

### Verify the cross-compiler

After step 5, confirm the full toolchain works end-to-end:

```bash
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep interpreter
rm a.out
# Must show: [/lib64/ld-linux-x86-64.so.2]
```

---

## Build order reference

### Cross-Toolchain (steps 1–5, installed to `$LFS/tools`)

| # | Package | Why |
|---|---------|-----|
| 1 | **Binutils** Pass 1 | cross-assembler and cross-linker; GCC needs them first |
| 2 | **GCC** Pass 1 | minimal cross-compiler; C/C++ only, bundles GMP/MPFR/MPC |
| 3 | **Linux API Headers** | kernel headers so Glibc knows how to call the kernel |
| 4 | **Glibc** | C library; run the sanity check after this — it is critical |
| 5 | **Libstdc++** Pass 1 | C++ stdlib for temporary tools in the next phase |
