#!/bin/bash
# LFS 12.4 §6.16 — Xz
# LZMA/XZ compression utility.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Xz"

cd "$LFS/sources"
rm -rf xz-*/            # leftovers of an interrupted run
tar -xf xz-*.tar.xz
cd xz-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/${PWD##*/}   # = xz-5.8.1

make
make DESTDIR=$LFS install

# .la files cause linker problems — remove them
rm -v "$LFS/usr/lib/liblzma.la"

cd "$LFS/sources"
rm -rf xz-*/

echo "<<< Xz done"
