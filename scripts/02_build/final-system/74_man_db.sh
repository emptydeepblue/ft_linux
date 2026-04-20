#!/bin/bash
# Final system 74/79 — Man-DB
set -euo pipefail
echo ">>> Man-DB"
cd /sources
tar -xf man-db-*.tar.xz
cd man-db-*/
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'") \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
make
make install
cd /sources && rm -rf man-db-*/
echo "<<< Man-DB done"
