#!/bin/bash
# Final system 11/79 — Bc
set -euo pipefail
echo ">>> Bc"
cd /sources
tar -xf bc-*.tar.xz
cd bc-*/
CC=gcc CFLAGS="-O3 -std=c11" ./configure --prefix=/usr -G -r
make
make install
cd /sources && rm -rf bc-*/
echo "<<< Bc done"
