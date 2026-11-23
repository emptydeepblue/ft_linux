#!/bin/bash
# LFS 12.4 §8.23 — MPC
set -euo pipefail
echo ">>> MPC"
cd /sources
tar -xf mpc-*.tar.gz
cd mpc-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/${PWD##*/}
make
make html
make install
make install-html
cd /sources && rm -rf mpc-*/
echo "<<< MPC done"
