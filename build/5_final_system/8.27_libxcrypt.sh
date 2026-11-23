#!/bin/bash
# LFS 12.4 §8.27 — Libxcrypt
set -euo pipefail
echo ">>> Libxcrypt"
cd /sources
rm -rf libxcrypt-*/            # leftovers of an interrupted run
tar -xf libxcrypt-*.tar.xz
cd libxcrypt-*/
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
make
make install
cd /sources && rm -rf libxcrypt-*/
echo "<<< Libxcrypt done"
