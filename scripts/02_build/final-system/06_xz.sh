#!/bin/bash
# Final system 06/79 — Xz
set -euo pipefail
echo ">>> Xz"
cd /sources
tar -xf xz-*.tar.xz
cd xz-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-$(cat doc/version)
make
make install
cd /sources && rm -rf xz-*/
echo "<<< Xz done"
