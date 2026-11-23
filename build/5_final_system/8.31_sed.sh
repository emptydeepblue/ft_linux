#!/bin/bash
# LFS 12.4 §8.31 — Sed
set -euo pipefail
echo ">>> Sed"
cd /sources
tar -xf sed-*.tar.xz
cd sed-*/
./configure --prefix=/usr
make
make html
make install
cd /sources && rm -rf sed-*/
echo "<<< Sed done"
