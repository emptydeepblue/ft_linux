#!/bin/bash
# Final system 23/79 — Libcap
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
