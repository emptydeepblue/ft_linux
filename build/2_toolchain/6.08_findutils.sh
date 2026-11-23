#!/bin/bash
# LFS 12.4 §6.8 — Findutils
# File search utilities (find, xargs).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Findutils"

cd "$LFS/sources"
rm -rf findutils-*/            # leftovers of an interrupted run
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
