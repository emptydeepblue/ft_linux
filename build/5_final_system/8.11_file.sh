#!/bin/bash
# LFS 12.4 §8.11 — File
set -euo pipefail
echo ">>> File"
cd /sources
tar -xf file-*.tar.gz
cd file-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf file-*/
echo "<<< File done"
