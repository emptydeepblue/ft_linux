#!/bin/bash
# LFS 12.4 §8.62 — Findutils
set -euo pipefail
echo ">>> Findutils"
cd /sources
tar -xf findutils-*.tar.xz
cd findutils-*/
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make install
cd /sources && rm -rf findutils-*/
echo "<<< Findutils done"
