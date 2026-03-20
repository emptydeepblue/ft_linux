#!/bin/bash
# Temporary tools step 16/17 — Make
# Build automation tool.
# --without-guile disables Guile scripting (not available in cross env).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Make"

cd "$LFS/sources"
tar -xf make-*.tar.gz
cd make-*/

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf make-*/

echo "<<< Make done"
