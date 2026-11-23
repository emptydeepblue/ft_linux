#!/bin/bash
# LFS 12.4 §6.10 — Grep
# Pattern matching utility.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Grep"

cd "$LFS/sources"
rm -rf grep-*/            # leftovers of an interrupted run
tar -xf grep-*.tar.xz
cd grep-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf grep-*/

echo "<<< Grep done"
