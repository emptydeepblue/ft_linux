#!/bin/bash
# LFS 12.4 §8.69 — Make
set -euo pipefail
echo ">>> Make"
cd /sources
rm -rf make-[0-9]*/            # leftovers of an interrupted run
tar -xf make-[0-9]*.tar.gz     # not make-ca-*
cd make-[0-9]*/
./configure --prefix=/usr
make
make install
cd /sources && rm -rf make-[0-9]*/
echo "<<< Make done"
