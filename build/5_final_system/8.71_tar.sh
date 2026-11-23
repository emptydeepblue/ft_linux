#!/bin/bash
# LFS 12.4 §8.71 — Tar
set -euo pipefail
echo ">>> Tar"
cd /sources
rm -rf tar-*/            # leftovers of an interrupted run
tar -xf tar-*.tar.xz
cd tar-*/
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make
make install
cd /sources && rm -rf tar-*/
echo "<<< Tar done"
