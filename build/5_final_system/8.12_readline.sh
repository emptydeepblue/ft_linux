#!/bin/bash
# LFS 12.4 §8.12 — Readline
set -euo pipefail
echo ">>> Readline"
cd /sources
tar -xf readline-*.tar.gz
cd readline-*/
sed -i '/MV.*old/d'       Makefile.in
sed -i '/{OLDSUFF}/c:'    support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/${PWD##*/}
make SHLIB_LIBS="-lncursesw"
make install
cd /sources && rm -rf readline-*/
echo "<<< Readline done"
