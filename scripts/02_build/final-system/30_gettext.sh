#!/bin/bash
# Final system 30/79 — Gettext (full build)
set -euo pipefail
echo ">>> Gettext"
cd /sources
tar -xf gettext-*.tar.xz
cd gettext-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-$(cat gettext-runtime/configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd /sources && rm -rf gettext-*/
echo "<<< Gettext done"
