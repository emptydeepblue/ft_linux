#!/bin/bash
# LFS 12.4 §8.22 — MPFR
set -euo pipefail
echo ">>> MPFR"
cd /sources
rm -rf mpfr-*/            # leftovers of an interrupted run
tar -xf mpfr-*.tar.xz
cd mpfr-*/
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/${PWD##*/}
make
make html
make install
make install-html
cd /sources && rm -rf mpfr-*/
echo "<<< MPFR done"
