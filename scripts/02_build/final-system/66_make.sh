#!/bin/bash
# Final system 66/79 — Make
set -euo pipefail
echo ">>> Make"
cd /sources
tar -xf make-*.tar.gz
cd make-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf make-*/
echo "<<< Make done"
