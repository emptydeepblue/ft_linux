#!/bin/bash
# LFS 12.4 §8.19 — Pkgconf (pkg-config)
set -euo pipefail
echo ">>> Pkgconf"
cd /sources
rm -rf pkgconf-*/            # leftovers of an interrupted run
tar -xf pkgconf-*.tar.xz
cd pkgconf-*/
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
cd /sources && rm -rf pkgconf-*/
echo "<<< Pkgconf done"
