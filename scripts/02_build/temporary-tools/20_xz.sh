#!/bin/bash
# Temporary tools step 20/17 — Xz
# LZMA/XZ compression utility.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Xz"

cd "$LFS/sources"
tar -xf xz-*.tar.xz
cd xz-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-$(cat doc/version)

make
make DESTDIR=$LFS install

# .la files cause linker problems — remove them
rm -v "$LFS/usr/lib/liblzma.la"

cd "$LFS/sources"
rm -rf xz-*/

echo "<<< Xz done"
