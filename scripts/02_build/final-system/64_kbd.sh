#!/bin/bash
# Final system 64/79 — Kbd
set -euo pipefail
echo ">>> Kbd"
cd /sources
tar -xf kbd-*.tar.xz
cd kbd-*/
# apply backspace patch if present
for p in ../kbd-*-backspace-*.patch; do
    [ -f "$p" ] && patch -Np1 -i "$p"
done
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //'            docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make install
cd /sources && rm -rf kbd-*/
echo "<<< Kbd done"
