#!/bin/bash
# LFS 12.4 §8.46 — Autoconf
set -euo pipefail
echo ">>> Autoconf"
cd /sources
rm -rf autoconf-*/            # leftovers of an interrupted run
tar -xf autoconf-*.tar.xz
cd autoconf-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf autoconf-*/
echo "<<< Autoconf done"
