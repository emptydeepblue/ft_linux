#!/bin/bash
# LFS 12.4 §8.25 — Acl
set -euo pipefail
echo ">>> Acl"
cd /sources
rm -rf acl-*/            # leftovers of an interrupted run
tar -xf acl-*.tar.xz
cd acl-*/
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf acl-*/
echo "<<< Acl done"
