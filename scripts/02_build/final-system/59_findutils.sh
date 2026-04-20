#!/bin/bash
# Final system 59/79 — Findutils
set -euo pipefail
echo ">>> Findutils"
cd /sources
tar -xf findutils-*.tar.xz
cd findutils-*/
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make install
cd /sources && rm -rf findutils-*/
echo "<<< Findutils done"
