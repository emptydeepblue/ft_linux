#!/bin/bash
# LFS 12.4 §6.13 — Patch
# Utility to apply diff patches to source files.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Patch"

cd "$LFS/sources"
rm -rf patch-*/            # leftovers of an interrupted run
tar -xf patch-*.tar.xz
cd patch-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf patch-*/

echo "<<< Patch done"
