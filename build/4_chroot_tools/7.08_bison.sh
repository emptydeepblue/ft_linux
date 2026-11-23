#!/bin/bash
# LFS 12.4 §7.8 — Bison
# Parser generator needed by several Ch.8 packages.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Bison"

cd /sources
tar -xf bison-*.tar.xz
cd bison-*/

./configure --prefix=/usr \
            --docdir=/usr/share/doc/${PWD##*/}

make
make install

cd /sources
rm -rf bison-*/

echo "<<< Bison done"
