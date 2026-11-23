#!/bin/bash
# LFS 12.4 §5.5 — Glibc
# The GNU C Library — the most critical component of the toolchain.
# After installation, a sanity check verifies the correct ELF interpreter path.
# Run as lfs user.
set -euo pipefail

echo ">>> Glibc"

cd "$LFS/sources"
tar -xf glibc-*.tar.xz
cd glibc-*/

# x86_64: compatibility symlinks for the dynamic linker
case $(uname -m) in
    x86_64)
        ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64"
        ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64/ld-lsb-x86-64.so.3"
    ;;
esac

# FHS: programs keep runtime data in /var/lib, not /var/db
patch -Np1 -i ../glibc-*-fhs-1.patch

mkdir -v build && cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
    --prefix=/usr                        \
    --host=$LFS_TGT                      \
    --build=$(../scripts/config.guess)   \
    --disable-nscd                       \
    libc_cv_slibdir=/usr/lib             \
    --enable-kernel=5.4

make
make DESTDIR=$LFS install

# Fix ldd's hardcoded /usr path
sed '/RTLDLIST=/s@/usr@@g' -i "$LFS/usr/bin/ldd"

# ── Sanity check (critical) ───────────────────────────────────────────────────
# The compiled binary must request /lib64/ld-linux-x86-64.so.2 as its
# ELF interpreter. If it requests anything else (e.g. a host path), the
# toolchain is broken and must not be used.

echo ""
echo "--- Glibc sanity check ---"
echo 'int main(){}' | "$LFS_TGT-gcc" -xc -

interpreter=$(readelf -l a.out | grep "program interpreter" | grep -o '\[.*\]' || true)
rm -f a.out

echo "  ELF interpreter: $interpreter"

expected="[/lib64/ld-linux-x86-64.so.2]"
if [ "$interpreter" = "$expected" ]; then
    echo "  OK: interpreter path is correct."
else
    echo ""
    echo "  FATAL: interpreter is '$interpreter', expected '$expected'."
    echo "  The toolchain is broken. Do NOT continue."
    echo "  Check that \$LFS, \$LFS_TGT, and Glibc configure flags are correct."
    exit 1
fi

cd "$LFS/sources"
rm -rf glibc-*/

echo "<<< Glibc done"
