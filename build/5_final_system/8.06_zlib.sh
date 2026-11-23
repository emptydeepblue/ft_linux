#!/bin/bash
# LFS 12.4 §8.6 — Zlib
set -euo pipefail
echo ">>> Zlib"
cd /sources
rm -rf zlib-*/            # leftovers of an interrupted run
tar -xf zlib-*.tar.gz
cd zlib-*/
./configure --prefix=/usr
make
make install
rm -fv /usr/lib/libz.a
cd /sources && rm -rf zlib-*/
echo "<<< Zlib done"
