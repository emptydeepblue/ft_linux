#!/bin/bash
# LFS 12.4 §5.2 — Binutils (Pass 1)
# Builds the cross-assembler and cross-linker that GCC needs.
# Run as lfs user.
set -euo pipefail

echo ">>> Binutils (Pass 1)"

cd "$LFS/sources"
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

cd "$LFS/sources"
rm -rf binutils-*/

echo "<<< Binutils (Pass 1) done"
