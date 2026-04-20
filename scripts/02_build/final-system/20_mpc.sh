#!/bin/bash
# Final system 20/79 — MPC
set -euo pipefail
echo ">>> MPC"
cd /sources
tar -xf mpc-*.tar.gz
cd mpc-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make html
make install
make install-html
cd /sources && rm -rf mpc-*/
echo "<<< MPC done"
