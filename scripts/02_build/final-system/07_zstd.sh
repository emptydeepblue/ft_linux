#!/bin/bash
# Final system 07/79 — Zstd
set -euo pipefail
echo ">>> Zstd"
cd /sources
tar -xf zstd-*.tar.gz
cd zstd-*/
make prefix=/usr
make prefix=/usr install
rm -v /usr/lib/libzstd.a
cd /sources && rm -rf zstd-*/
echo "<<< Zstd done"
