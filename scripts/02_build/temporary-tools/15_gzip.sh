#!/bin/bash
# Temporary tools step 15/17 — Gzip
# File compression/decompression utility.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Gzip"

cd "$LFS/sources"
tar -xf gzip-*.tar.xz
cd gzip-*/

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf gzip-*/

echo "<<< Gzip done"
