#!/bin/bash
# Final system 62/79 — Gzip
set -euo pipefail
echo ">>> Gzip"
cd /sources
tar -xf gzip-*.tar.xz
cd gzip-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf gzip-*/
echo "<<< Gzip done"
