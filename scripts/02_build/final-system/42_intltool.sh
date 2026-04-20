#!/bin/bash
# Final system 42/79 — Intltool
set -euo pipefail
echo ">>> Intltool"
cd /sources
tar -xf intltool-*.tar.gz
cd intltool-*/
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make install
install -v -Dm644 doc/I18N-HOWTO \
    /usr/share/doc/intltool-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")/I18N-HOWTO
cd /sources && rm -rf intltool-*/
echo "<<< Intltool done"
