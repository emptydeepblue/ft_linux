#!/bin/bash
# LFS 12.4 §8.68 — Libpipeline
set -euo pipefail
echo ">>> Libpipeline"
cd /sources
rm -rf libpipeline-*/            # leftovers of an interrupted run
tar -xf libpipeline-*.tar.gz
cd libpipeline-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf libpipeline-*/
echo "<<< Libpipeline done"
