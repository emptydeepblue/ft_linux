#!/bin/bash
# Final system 31/79 — Bison
set -euo pipefail
echo ">>> Bison"
cd /sources
tar -xf bison-*.tar.xz
cd bison-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf bison-*/
echo "<<< Bison done"
