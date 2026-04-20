#!/bin/bash
# Final system 36/79 — Gperf
set -euo pipefail
echo ">>> Gperf"
cd /sources
tar -xf gperf-*.tar.gz
cd gperf-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/gperf-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf gperf-*/
echo "<<< Gperf done"
