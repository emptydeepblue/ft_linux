#!/bin/bash
# LFS 12.4 §6.17 — Binutils (Pass 2)
# Rebuilds the assembler and linker targeting $LFS_TGT,
# now with shared library support since Glibc is available.
# Installed to $LFS (not $LFS/tools).
# Run as lfs user.
set -euo pipefail

echo ">>> Binutils (Pass 2)"

cd "$LFS/sources"
tar -xf binutils-*.tar.xz
cd binutils-*/

# Fix a libtool issue that breaks shared library builds
sed '6031s/$add_dir//' -i ltmain.sh   # line number from the 12.4 book

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

# Static archives and .la files are not needed for the temporary toolchain
rm -v "$LFS"/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

cd "$LFS/sources"
rm -rf binutils-*/

echo "<<< Binutils (Pass 2) done"
