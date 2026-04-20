#!/bin/bash
# Final system 43/79 — Autoconf
set -euo pipefail
echo ">>> Autoconf"
cd /sources
tar -xf autoconf-*.tar.xz
cd autoconf-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf autoconf-*/
echo "<<< Autoconf done"
