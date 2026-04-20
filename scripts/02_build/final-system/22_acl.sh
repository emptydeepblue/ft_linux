#!/bin/bash
# Final system 22/79 — Acl
set -euo pipefail
echo ">>> Acl"
cd /sources
tar -xf acl-*.tar.xz
cd acl-*/
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf acl-*/
echo "<<< Acl done"
