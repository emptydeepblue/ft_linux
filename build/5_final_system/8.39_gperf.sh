#!/bin/bash
# LFS 12.4 §8.39 — Gperf
set -euo pipefail
echo ">>> Gperf"
cd /sources
tar -xf gperf-*.tar.gz
cd gperf-*/
./configure --prefix=/usr \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf gperf-*/
echo "<<< Gperf done"
