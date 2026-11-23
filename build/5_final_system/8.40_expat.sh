#!/bin/bash
# LFS 12.4 §8.40 — Expat
set -euo pipefail
echo ">>> Expat"
cd /sources
rm -rf expat-*/            # leftovers of an interrupted run
tar -xf expat-*.tar.xz
cd expat-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf expat-*/
echo "<<< Expat done"
