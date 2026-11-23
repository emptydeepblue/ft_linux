#!/bin/bash
# LFS 12.4 §7.11 — Texinfo
# Documentation system needed by several Ch.8 packages.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Texinfo"

cd /sources
rm -rf texinfo-*/            # leftovers of an interrupted run
tar -xf texinfo-*.tar.xz
cd texinfo-*/

./configure --prefix=/usr

make
make install

cd /sources
rm -rf texinfo-*/

echo "<<< Texinfo done"
