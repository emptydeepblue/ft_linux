#!/bin/bash
# LFS 12.4 §8.45 — Intltool
set -euo pipefail
echo ">>> Intltool"
cd /sources
tar -xf intltool-*.tar.gz
cd intltool-*/
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/${PWD##*/}/I18N-HOWTO
cd /sources && rm -rf intltool-*/
echo "<<< Intltool done"
