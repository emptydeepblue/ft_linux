#!/bin/bash
# LFS 12.4 §8.78 — Procps-ng
set -euo pipefail
echo ">>> Procps-ng"
cd /sources
rm -rf procps-*/            # leftovers of an interrupted run
tar -xf procps-*.tar.xz
cd procps-*/
./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/${PWD##*/} \
            --disable-static                         \
            --disable-kill                           \
            --enable-watch8bit
make
make install
cd /sources && rm -rf procps-*/
echo "<<< Procps-ng done"
