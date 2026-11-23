#!/bin/bash
# LFS 12.4 §6.9 — Gawk
# GNU AWK implementation for text processing.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Gawk"

cd "$LFS/sources"
rm -rf gawk-*/            # leftovers of an interrupted run
tar -xf gawk-*.tar.xz
cd gawk-*/

# Remove references to 'extras' which are not cross-compiled
sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf gawk-*/

echo "<<< Gawk done"
