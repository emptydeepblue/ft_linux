#!/bin/bash
# LFS 12.4 §8.24 — Attr
set -euo pipefail
echo ">>> Attr"
cd /sources
tar -xf attr-*.tar.gz
cd attr-*/
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf attr-*/
echo "<<< Attr done"
