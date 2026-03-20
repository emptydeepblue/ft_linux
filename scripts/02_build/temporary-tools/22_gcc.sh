#!/bin/bash
# Temporary tools step 22/17 — GCC (Pass 2)
# Full cross-compiler with shared libraries and threads, now that
# Glibc and Libstdc++ are in place. GMP, MPFR, MPC bundled inside.
# Installed to $LFS (not $LFS/tools).
# Run as lfs user.
set -euo pipefail

echo ">>> GCC (Pass 2)"

cd "$LFS/sources"
tar -xf gcc-*.tar.xz
cd gcc-*/

# Bundle required math libraries inside the GCC tree
tar -xf ../mpfr-*.tar.xz && mv -v mpfr-* mpfr
tar -xf ../gmp-*.tar.xz  && mv -v gmp-*  gmp
tar -xf ../mpc-*.tar.xz  && mv -v mpc-*  mpc

# x86_64: redirect 64-bit lib dir from lib64 → lib
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
esac

# Use the POSIX thread header (gthr-posix.h) for libgcc and libstdc++
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

# Provide cc as a convenience alias for gcc
ln -sv gcc "$LFS/usr/bin/cc"

cd "$LFS/sources"
rm -rf gcc-*/

echo "<<< GCC (Pass 2) done"
