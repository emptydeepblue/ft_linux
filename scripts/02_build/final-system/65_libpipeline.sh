#!/bin/bash
# Final system 65/79 — Libpipeline
set -euo pipefail
echo ">>> Libpipeline"
cd /sources
tar -xf libpipeline-*.tar.gz
cd libpipeline-*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf libpipeline-*/
echo "<<< Libpipeline done"
