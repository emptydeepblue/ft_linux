#!/bin/bash
# LFS 12.4 §8.47 — Automake
set -euo pipefail
echo ">>> Automake"
cd /sources
tar -xf automake-*.tar.xz
cd automake-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf automake-*/
echo "<<< Automake done"
