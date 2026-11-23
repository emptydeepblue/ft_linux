#!/bin/bash
# LFS 12.4 §8.60 — Diffutils (native final build)
set -euo pipefail
echo ">>> Diffutils"
cd /sources
rm -rf diffutils-*/            # leftovers of an interrupted run
tar -xf diffutils-*.tar.xz
cd diffutils-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf diffutils-*/
echo "<<< Diffutils done"
