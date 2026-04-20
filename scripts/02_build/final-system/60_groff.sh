#!/bin/bash
# Final system 60/79 — Groff
set -euo pipefail
echo ">>> Groff"
cd /sources
tar -xf groff-*.tar.gz
cd groff-*/
PAGE=letter ./configure --prefix=/usr
make
make install
cd /sources && rm -rf groff-*/
echo "<<< Groff done"
