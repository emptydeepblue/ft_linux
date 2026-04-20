#!/bin/bash
# Final system 44/79 — Automake
set -euo pipefail
echo ">>> Automake"
cd /sources
tar -xf automake-*.tar.xz
cd automake-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/automake-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf automake-*/
echo "<<< Automake done"
