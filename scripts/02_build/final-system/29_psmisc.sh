#!/bin/bash
# Final system 29/79 — Psmisc
set -euo pipefail
echo ">>> Psmisc"
cd /sources
tar -xf psmisc-*.tar.xz
cd psmisc-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf psmisc-*/
echo "<<< Psmisc done"
