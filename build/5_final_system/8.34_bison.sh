#!/bin/bash
# LFS 12.4 §8.34 — Bison
set -euo pipefail
echo ">>> Bison"
cd /sources
rm -rf bison-*/            # leftovers of an interrupted run
tar -xf bison-*.tar.xz
cd bison-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf bison-*/
echo "<<< Bison done"
