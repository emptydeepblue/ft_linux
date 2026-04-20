#!/bin/bash
# Final system 24/79 — Libxcrypt
set -euo pipefail
echo ">>> Libxcrypt"
cd /sources
tar -xf libxcrypt-*.tar.xz
cd libxcrypt-*/
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens     \
            CFLAGS="-O2 -Wno-error=unterminated-string-initialization"
make
make install
cd /sources && rm -rf libxcrypt-*/
echo "<<< Libxcrypt done"
