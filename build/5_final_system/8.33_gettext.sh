#!/bin/bash
# LFS 12.4 §8.33 — Gettext (full build)
set -euo pipefail
echo ">>> Gettext"
cd /sources
rm -rf gettext-*/            # leftovers of an interrupted run
tar -xf gettext-*.tar.xz
cd gettext-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd /sources && rm -rf gettext-*/
echo "<<< Gettext done"
