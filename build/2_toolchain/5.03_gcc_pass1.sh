#!/bin/bash
# LFS 12.4 §5.3 — GCC (Pass 1)
# Builds a minimal cross-compiler (C/C++ only, no shared libs, no threads).
# GMP, MPFR, MPC are bundled inside the GCC tree.
# Run as lfs user.
set -euo pipefail

echo ">>> GCC (Pass 1)"

cd "$LFS/sources"
rm -rf gcc-*/            # leftovers of an interrupted run
tar -xf gcc-*.tar.xz
cd gcc-*/

# Bundle required math libraries inside the GCC tree
# (any compression: mpc is a .tar.gz in 12.4)
tar -xf ../mpfr-*.tar.* && mv -v mpfr-* mpfr
tar -xf ../gmp-*.tar.*  && mv -v gmp-*  gmp
tar -xf ../mpc-*.tar.*  && mv -v mpc-*  mpc

# On x86_64: default 64-bit lib dir to "lib" (not "lib64")
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
esac

mkdir -v build && cd build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.42 \
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

make
make install

# Create the limited limits.h header GCC needs for building Glibc
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    "$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h"

cd "$LFS/sources"
rm -rf gcc-*/

echo "<<< GCC (Pass 1) done"
