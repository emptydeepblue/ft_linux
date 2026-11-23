#!/bin/bash
# LFS 12.4 §6.14 — Sed
# Stream editor for filtering and transforming text.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Sed"

cd "$LFS/sources"
rm -rf sed-*/            # leftovers of an interrupted run
tar -xf sed-*.tar.xz
cd sed-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf sed-*/

echo "<<< Sed done"
