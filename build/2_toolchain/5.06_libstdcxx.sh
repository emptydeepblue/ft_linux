#!/bin/bash
# LFS 12.4 §5.6 — Libstdc++ (Pass 1)
# Extracted from the GCC source tree. Pass 1 is cross-compiled and installed
# into $LFS so that the temporary C++ tools in Chapter 6 can link against it.
# Run as lfs user.
set -euo pipefail

echo ">>> Libstdc++ (Pass 1)"

cd "$LFS/sources"
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

# .la files are only needed by libtool and cause problems if left here
rm -v "$LFS"/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd "$LFS/sources"
rm -rf gcc-*/

echo "<<< Libstdc++ (Pass 1) done"
