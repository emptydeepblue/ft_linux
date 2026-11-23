#!/bin/bash
# LFS 12.4 §8.14 — Bc
set -euo pipefail
echo ">>> Bc"
cd /sources
tar -xf bc-*.tar.xz
cd bc-*/
CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
make
make install
cd /sources && rm -rf bc-*/
echo "<<< Bc done"
