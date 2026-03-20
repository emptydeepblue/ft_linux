# Cross-Compiled Temporary Tools — ft_linux

These 17 packages are cross-compiled with `--host=$LFS_TGT` and installed directly into `$LFS` (not `$LFS/tools`). They form the minimal userspace needed to enter the chroot and build the final system natively.

**All commands run as the `lfs` user with the environment sourced.**

---

## Quick run (automated)

```bash
# build all 17 steps
bash scripts/02_build/02_run_temporary_tools.sh

# resume from step N if a step failed
bash scripts/02_build/02_run_temporary_tools.sh <N>
```

Individual scripts (run in order):
- [06_m4.sh](../../scripts/02_build/temporary-tools/06_m4.sh)
- [07_ncurses.sh](../../scripts/02_build/temporary-tools/07_ncurses.sh)
- [08_bash.sh](../../scripts/02_build/temporary-tools/08_bash.sh)
- [09_coreutils.sh](../../scripts/02_build/temporary-tools/09_coreutils.sh)
- [10_diffutils.sh](../../scripts/02_build/temporary-tools/10_diffutils.sh)
- [11_file.sh](../../scripts/02_build/temporary-tools/11_file.sh)
- [12_findutils.sh](../../scripts/02_build/temporary-tools/12_findutils.sh)
- [13_gawk.sh](../../scripts/02_build/temporary-tools/13_gawk.sh)
- [14_grep.sh](../../scripts/02_build/temporary-tools/14_grep.sh)
- [15_gzip.sh](../../scripts/02_build/temporary-tools/15_gzip.sh)
- [16_make.sh](../../scripts/02_build/temporary-tools/16_make.sh)
- [17_patch.sh](../../scripts/02_build/temporary-tools/17_patch.sh)
- [18_sed.sh](../../scripts/02_build/temporary-tools/18_sed.sh)
- [19_tar.sh](../../scripts/02_build/temporary-tools/19_tar.sh)
- [20_xz.sh](../../scripts/02_build/temporary-tools/20_xz.sh)
- [21_binutils.sh](../../scripts/02_build/temporary-tools/21_binutils.sh)
- [22_gcc.sh](../../scripts/02_build/temporary-tools/22_gcc.sh)

---

## Manual run (step by step)

```bash
sudo su - lfs
source ~/.bash_profile
```

---

### Step 6 — M4

Macro processor. Required by Autoconf, Bison, and others.

```bash
cd $LFS/sources
tar -xf m4-*.tar.xz
cd m4-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf m4-*/
```

---

### Step 7 — Ncurses

Terminal handling library. Required by Bash, Less, Vim, and others.
A native `tic` binary is built first so the install can process terminfo entries.

<!-- MISSINIG 
wget -c --show-progress \
    https://invisible-island.net/archives/ncurses/ncurses-6.5.tar.gz \
    -P $LFS/sources -->

```bash
cd $LFS/sources
tar -xf ncurses-*.tar.gz
cd ncurses-*/

sed -i s/mawk// configure

# build a host-native tic
mkdir build
pushd build
    ../configure --disable-stripping
    make -C include
    make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping

make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

# provide the non-wide libncurses.so many packages expect
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so

# expose wide-character functions unconditionally
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $LFS/usr/include/curses.h

cd $LFS/sources
rm -rf ncurses-*/
```

---

### Step 8 — Bash

The shell used inside the chroot environment.

```bash
cd $LFS/sources
tar -xf bash-*.tar.gz
cd bash-*/

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc              \
            bash_cv_strtold_broken=no

make
make DESTDIR=$LFS install

# provide /bin/sh for scripts that expect it
ln -sv bash $LFS/bin/sh

cd $LFS/sources
rm -rf bash-*/
```

---

### Step 9 — Coreutils

Core file, shell, and text utilities (`ls`, `cp`, `mv`, `rm`, `chmod`, etc.).

```bash
cd $LFS/sources
tar -xf coreutils-*.tar.xz
cd coreutils-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

# chroot belongs in /usr/sbin
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

cd $LFS/sources
rm -rf coreutils-*/
```

---

### Step 10 — Diffutils

File comparison utilities (`diff`, `cmp`).

```bash
cd $LFS/sources
tar -xf diffutils-*.tar.xz
cd diffutils-*/

./configure --prefix=/usr                       \
            --host=$LFS_TGT                     \
            --build=$(./build-aux/config.guess) \
            ac_cv_func_strcasecmp=yes           \
            gl_cv_func_strcasecmp_works=yes

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf diffutils-*/
```

---

### Step 11 — File

Determines file types by inspecting content. Needs a native `file` binary at configure time.

```bash
cd $LFS/sources
tar -xf file-*.tar.gz
cd file-*/

# build host-native file binary first
mkdir build
pushd build
    ../configure --disable-bzlib      \
                 --disable-libseccomp \
                 --disable-xzlib      \
                 --disable-zlib
    make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la

cd $LFS/sources
rm -rf file-*/
```

---

### Step 12 — Findutils

File search utilities (`find`, `xargs`).

```bash
cd $LFS/sources
tar -xf findutils-*.tar.xz
cd findutils-*/

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf findutils-*/
```

---

### Step 13 — Gawk

GNU AWK implementation for text processing.

```bash
cd $LFS/sources
tar -xf gawk-*.tar.xz
cd gawk-*/

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf gawk-*/
```

---

### Step 14 — Grep

Pattern matching utility.

```bash
cd $LFS/sources
tar -xf grep-*.tar.xz
cd grep-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf grep-*/
```

---

### Step 15 — Gzip

File compression/decompression.

```bash
cd $LFS/sources
tar -xf gzip-*.tar.xz
cd gzip-*/

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf gzip-*/
```

---

### Step 16 — Make

Build automation tool. `--without-guile` disables Guile scripting (unavailable in the cross environment).

```bash
cd $LFS/sources
tar -xf make-*.tar.gz
cd make-*/

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf make-*/
```

---

### Step 17 — Patch

Applies diff patches to source files.

```bash
cd $LFS/sources
tar -xf patch-*.tar.xz
cd patch-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf patch-*/
```

---

### Step 18 — Sed

Stream editor for filtering and transforming text.

```bash
cd $LFS/sources
tar -xf sed-*.tar.xz
cd sed-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf sed-*/
```

---

### Step 19 — Tar

Archive creation and extraction.

```bash
cd $LFS/sources
tar -xf tar-*.tar.xz
cd tar-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources
rm -rf tar-*/
```

---

### Step 20 — Xz

LZMA/XZ compression utility.

```bash
cd $LFS/sources
tar -xf xz-*.tar.xz
cd xz-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-$(cat doc/version)

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd $LFS/sources
rm -rf xz-*/
```

---

### Step 21 — Binutils (Pass 2)

Rebuilds the assembler and linker targeting `$LFS_TGT`, now with shared library support since Glibc is in place.

```bash
cd $LFS/sources
tar -xf binutils-*.tar.xz
cd binutils-*/

# fix a libtool issue that breaks shared library builds
sed '6009s/$add_dir//' -i ltmain.sh

rm -rf build && mkdir -v build && cd build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu

make
make DESTDIR=$LFS install

# remove static archives and .la files not needed in temp toolchain
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la} 2>/dev/null || true

cd $LFS/sources
rm -rf binutils-*/
```

---

### Step 22 — GCC (Pass 2)

Full cross-compiler with shared libraries and threads enabled. GMP, MPFR, MPC bundled inside.

```bash
cd $LFS/sources
tar -xf gcc-*.tar.xz
cd gcc-*/

# bundle required math libraries
tar -xf ../mpfr-*.tar.xz && mv -v mpfr-* mpfr
tar -xf ../gmp-*.tar.xz  && mv -v gmp-*  gmp
tar -xf ../mpc-*.tar.xz  && mv -v mpc-*  mpc

# x86_64: redirect 64-bit lib dir from lib64 → lib
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
esac

# use POSIX thread header for libgcc and libstdc++
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

rm -rf build && mkdir -v build && cd build

../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET="-L$PWD/$LFS_TGT/libgcc"   \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++

make
make DESTDIR=$LFS install

# provide cc as a convenience alias
ln -sv gcc $LFS/usr/bin/cc

cd $LFS/sources
rm -rf gcc-*/
```

---

## Build order reference

| # | Package | Why |
|---|---------|-----|
| 6 | **M4** | macro processor — first because Bison/Flex need it |
| 7 | **Ncurses** | terminal library — Bash links against it |
| 8 | **Bash** | shell for chroot |
| 9 | **Coreutils** | `ls`, `cp`, `mv`, etc. — fundamental utilities |
| 10 | **Diffutils** | `diff`, `cmp` |
| 11 | **File** | file type detection |
| 12 | **Findutils** | `find`, `xargs` |
| 13 | **Gawk** | AWK — used by many build scripts |
| 14 | **Grep** | pattern matching |
| 15 | **Gzip** | compression — needed to unpack some sources |
| 16 | **Make** | build automation |
| 17 | **Patch** | apply source patches |
| 18 | **Sed** | stream editor |
| 19 | **Tar** | archiving — needed to unpack sources inside chroot |
| 20 | **Xz** | LZMA compression |
| 21 | **Binutils** Pass 2 | assembler/linker rebuilt with shared lib support |
| 22 | **GCC** Pass 2 | full compiler rebuilt with threads and shared libs |

**Next:** [08 Chroot Setup](08_chroot_setup.md)
