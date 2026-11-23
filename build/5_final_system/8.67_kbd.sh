#!/bin/bash
# LFS 12.4 §8.67 — Kbd
set -euo pipefail
echo ">>> Kbd"
cd /sources
rm -rf kbd-*/            # leftovers of an interrupted run
tar -xf kbd-*.tar.xz
cd kbd-*/
patch -Np1 -i ../kbd-*-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //'            docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make install
cd /sources && rm -rf kbd-*/
echo "<<< Kbd done"
