#!/bin/bash
# LFS 12.4 §8.8 — Xz
set -euo pipefail
echo ">>> Xz"
cd /sources
tar -xf xz-*.tar.xz
cd xz-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf xz-*/
echo "<<< Xz done"
