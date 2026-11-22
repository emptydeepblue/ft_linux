#!/bin/bash
# Final system 48/79 — Libffi
set -euo pipefail
echo ">>> Libffi"
cd /sources
tar -xf "$(ls libffi-*.tar.gz | sort -V | tail -1)"
cd libffi-*/
./configure --prefix=/usr          \
            --disable-static       \
            --without-gcc-arch 
make
make install
cd /sources && rm -rf libffi-*/
echo "<<< Libffi done"
