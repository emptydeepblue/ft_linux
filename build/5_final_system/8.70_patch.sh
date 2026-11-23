#!/bin/bash
# LFS 12.4 §8.70 — Patch
set -euo pipefail
echo ">>> Patch"
cd /sources
rm -rf patch-*/            # leftovers of an interrupted run
tar -xf patch-*.tar.xz
cd patch-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf patch-*/
echo "<<< Patch done"
