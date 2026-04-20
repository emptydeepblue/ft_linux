#!/bin/bash
# Final system 21/79 — Attr
set -euo pipefail
echo ">>> Attr"
cd /sources
tar -xf attr-*.tar.gz
cd attr-*/
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf attr-*/
echo "<<< Attr done"
