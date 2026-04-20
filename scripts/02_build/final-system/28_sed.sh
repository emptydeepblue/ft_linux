#!/bin/bash
# Final system 28/79 — Sed
set -euo pipefail
echo ">>> Sed"
cd /sources
tar -xf sed-*.tar.xz
cd sed-*/
./configure --prefix=/usr
make
make html
make install
cd /sources && rm -rf sed-*/
echo "<<< Sed done"
