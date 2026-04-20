#!/bin/bash
# Final system 57/79 — Diffutils (native final build)
set -euo pipefail
echo ">>> Diffutils"
cd /sources
tar -xf diffutils-*.tar.xz
cd diffutils-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf diffutils-*/
echo "<<< Diffutils done"
