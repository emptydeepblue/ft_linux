#!/bin/bash
# LFS 12.4 §8.37 — Libtool
set -euo pipefail
echo ">>> Libtool"
cd /sources
tar -xf libtool-*.tar.xz
cd libtool-*/
./configure --prefix=/usr
make
make install
rm -fv /usr/lib/libltdl.a
cd /sources && rm -rf libtool-*/
echo "<<< Libtool done"
