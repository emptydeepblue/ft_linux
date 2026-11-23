#!/bin/bash
# LFS 12.4 §6.12 — Make
# Build automation tool.
# --without-guile disables Guile scripting (not available in cross env).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Make"

cd "$LFS/sources"
rm -rf make-[0-9]*/            # leftovers of an interrupted run
tar -xf make-[0-9]*.tar.gz     # not make-ca-*
cd make-[0-9]*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf make-[0-9]*/

echo "<<< Make done"
