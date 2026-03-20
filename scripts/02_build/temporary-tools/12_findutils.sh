#!/bin/bash
# Temporary tools step 12/17 — Findutils
# File search utilities (find, xargs).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Findutils"

cd "$LFS/sources"
tar -xf findutils-*.tar.xz
cd findutils-*/

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf findutils-*/

echo "<<< Findutils done"
