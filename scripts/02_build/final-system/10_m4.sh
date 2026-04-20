#!/bin/bash
# Final system 10/79 — M4
set -euo pipefail
echo ">>> M4"
cd /sources
tar -xf m4-*.tar.xz
cd m4-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf m4-*/
echo "<<< M4 done"
