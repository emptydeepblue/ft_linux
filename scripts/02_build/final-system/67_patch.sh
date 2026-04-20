#!/bin/bash
# Final system 67/79 — Patch
set -euo pipefail
echo ">>> Patch"
cd /sources
tar -xf patch-*.tar.xz
cd patch-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf patch-*/
echo "<<< Patch done"
