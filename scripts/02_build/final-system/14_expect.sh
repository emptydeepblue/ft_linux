#!/bin/bash
# Final system 14/79 — Expect
set -euo pipefail
echo ">>> Expect"
cd /sources
tar -xf expect*.tar.gz
cd expect*/
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
./configure --prefix=/usr              \
            --with-tcl=/usr/lib        \
            --enable-shared            \
            --mandir=/usr/share/man    \
            --with-tclinclude=/usr/include
make
make install
ln -svf expect$(ls /usr/lib/ | grep '^expect[0-9]' | tail -1 | grep -o '[0-9.]*') /usr/lib/expect
cd /sources && rm -rf expect*/
echo "<<< Expect done"
