#!/bin/bash
# LFS 12.4 §8.9 — Lz4
set -euo pipefail
echo ">>> Lz4"
cd /sources
tar -xf lz4-*.tar.gz
cd lz4-*/
make BUILD_STATIC=no PREFIX=/usr
make BUILD_STATIC=no PREFIX=/usr install
cd /sources && rm -rf lz4-*/
echo "<<< Lz4 done"
