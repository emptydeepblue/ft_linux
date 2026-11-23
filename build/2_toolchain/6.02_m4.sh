#!/bin/bash
# LFS 12.4 §6.2 — M4
# Macro processor, required by Autoconf and Bison.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> M4"

cd "$LFS/sources"
tar -xf m4-*.tar.xz
cd m4-*/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf m4-*/

echo "<<< M4 done"
