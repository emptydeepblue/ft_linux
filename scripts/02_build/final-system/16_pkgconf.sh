#!/bin/bash
# Final system 16/79 — Pkgconf (pkg-config)
set -euo pipefail
echo ">>> Pkgconf"
cd /sources
tar -xf pkgconf-*.tar.xz
cd pkgconf-*/
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
cd /sources && rm -rf pkgconf-*/
echo "<<< Pkgconf done"
