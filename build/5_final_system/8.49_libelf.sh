#!/bin/bash
# LFS 12.4 §8.49 — Libelf (from Elfutils — libelf only)
set -euo pipefail
echo ">>> Libelf"
cd /sources
rm -rf elfutils-*/            # leftovers of an interrupted run
tar -xf elfutils-*.tar.bz2
cd elfutils-*/
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make -C libelf
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm -fv /usr/lib/libelf.a
cd /sources && rm -rf elfutils-*/
echo "<<< Libelf done"
