#!/bin/bash
# Chroot tools step 24/28 — Bison
# Parser generator needed by several Ch.8 packages.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Bison"

cd /sources
tar -xf bison-*.tar.xz
cd bison-*/

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-$(cat version)

make
make install

cd /sources
rm -rf bison-*/

echo "<<< Bison done"
