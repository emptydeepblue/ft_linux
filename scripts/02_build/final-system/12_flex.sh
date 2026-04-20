#!/bin/bash
# Final system 12/79 — Flex
set -euo pipefail
echo ">>> Flex"
cd /sources
tar -xf flex-*.tar.gz
cd flex-*/
./configure --prefix=/usr \
            --disable-static \
            --docdir=/usr/share/doc/flex-$(cat version)
make
make install
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1
cd /sources && rm -rf flex-*/
echo "<<< Flex done"
