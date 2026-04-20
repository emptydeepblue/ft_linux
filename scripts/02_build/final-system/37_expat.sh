#!/bin/bash
# Final system 37/79 — Expat
set -euo pipefail
echo ">>> Expat"
cd /sources
tar -xf expat-*.tar.xz
cd expat-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf expat-*/
echo "<<< Expat done"
