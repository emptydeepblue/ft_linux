#!/bin/bash
# LFS 12.4 §8.63 — Groff
set -euo pipefail
echo ">>> Groff"
cd /sources
rm -rf groff-*/            # leftovers of an interrupted run
tar -xf groff-*.tar.gz
cd groff-*/
# A4: European paper size (book: PAGE=<paper_size>)
PAGE=A4 ./configure --prefix=/usr
make
make install
cd /sources && rm -rf groff-*/
echo "<<< Groff done"
