#!/bin/bash
# LFS 12.4 §8.35 — Grep
set -euo pipefail
echo ">>> Grep"
cd /sources
tar -xf grep-*.tar.xz
cd grep-*/
sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make
make install
cd /sources && rm -rf grep-*/
echo "<<< Grep done"
