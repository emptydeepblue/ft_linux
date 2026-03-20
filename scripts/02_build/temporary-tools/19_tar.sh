#!/bin/bash
# Temporary tools step 19/17 — Tar
# Archive creation and extraction utility.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Tar"

cd "$LFS/sources"
tar -xf tar-*.tar.xz
cd tar-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf tar-*/

echo "<<< Tar done"
