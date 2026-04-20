#!/bin/bash
# Final system 58/79 — Gawk
set -euo pipefail
echo ">>> Gawk"
cd /sources
tar -xf gawk-*.tar.xz
cd gawk-*/
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
make install
cd /sources && rm -rf gawk-*/
echo "<<< Gawk done"
