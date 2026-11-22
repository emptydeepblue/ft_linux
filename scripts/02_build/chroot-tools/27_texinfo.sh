#!/bin/bash
# Chroot tools step 27/29 — Texinfo
# Documentation system needed by several Ch.8 packages.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Texinfo"

cd /sources
tar -xf texinfo-*.tar.xz
cd texinfo-*/

./configure --prefix=/usr

make
make install

cd /sources
rm -rf texinfo-*/

echo "<<< Texinfo done"
