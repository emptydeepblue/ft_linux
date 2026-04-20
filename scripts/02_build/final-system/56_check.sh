#!/bin/bash
# Final system 56/79 — Check (unit test framework for C)
set -euo pipefail
echo ">>> Check"
cd /sources
tar -xf check-*.tar.gz
cd check-*/
./configure --prefix=/usr --disable-static
make
make install
cd /sources && rm -rf check-*/
echo "<<< Check done"
