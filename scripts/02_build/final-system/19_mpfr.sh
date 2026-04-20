#!/bin/bash
# Final system 19/79 — MPFR
set -euo pipefail
echo ">>> MPFR"
cd /sources
tar -xf mpfr-*.tar.xz
cd mpfr-*/
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make html
make install
make install-html
cd /sources && rm -rf mpfr-*/
echo "<<< MPFR done"
