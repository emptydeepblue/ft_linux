#!/bin/bash
# LFS 12.4 §8.50 — Libffi
set -euo pipefail
echo ">>> Libffi"
cd /sources
rm -rf libffi-*/            # leftovers of an interrupted run
tar -xf "$(ls libffi-*.tar.gz | sort -V | tail -1)"
cd libffi-*/
./configure --prefix=/usr          \
            --disable-static       \
            --without-gcc-arch 
make
make install
cd /sources && rm -rf libffi-*/
echo "<<< Libffi done"
