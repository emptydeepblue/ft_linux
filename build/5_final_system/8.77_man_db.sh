#!/bin/bash
# LFS 12.4 §8.77 — Man-DB
set -euo pipefail
echo ">>> Man-DB"
cd /sources
tar -xf man-db-*.tar.xz
cd man-db-*/
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/${PWD##*/} \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=           \
            --with-systemdsystemunitdir=
make
make install
cd /sources && rm -rf man-db-*/
echo "<<< Man-DB done"
