#!/bin/bash
# LFS 12.4 §8.26 — Libcap
set -euo pipefail
echo ">>> Libcap"
cd /sources
tar -xf libcap-*.tar.xz
cd libcap-*/
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make prefix=/usr lib=lib install
cd /sources && rm -rf libcap-*/
echo "<<< Libcap done"
