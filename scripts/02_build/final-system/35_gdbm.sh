#!/bin/bash
# Final system 35/79 — GDBM
set -euo pipefail
echo ">>> GDBM"
cd /sources
tar -xf gdbm-*.tar.gz
cd gdbm-*/
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
make install
cd /sources && rm -rf gdbm-*/
echo "<<< GDBM done"
