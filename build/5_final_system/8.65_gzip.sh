#!/bin/bash
# LFS 12.4 §8.65 — Gzip
set -euo pipefail
echo ">>> Gzip"
cd /sources
rm -rf gzip-*/            # leftovers of an interrupted run
tar -xf gzip-*.tar.xz
cd gzip-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf gzip-*/
echo "<<< Gzip done"
