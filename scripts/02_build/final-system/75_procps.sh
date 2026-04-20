#!/bin/bash
# Final system 75/79 — Procps-ng
set -euo pipefail
echo ">>> Procps-ng"
cd /sources
tar -xf procps-*.tar.xz
cd procps-*/
sed -i '/#include "xalloc.h"/a #include <stdbool.h>' src/watch.c
./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'") \
            --disable-static                         \
            --disable-kill
make
make install
cd /sources && rm -rf procps-*/
echo "<<< Procps-ng done"
