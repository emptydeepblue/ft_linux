#!/bin/bash
# LFS 12.4 §8.38 — GDBM
set -euo pipefail
echo ">>> GDBM"
cd /sources
rm -rf gdbm-*/            # leftovers of an interrupted run
tar -xf gdbm-*.tar.gz
cd gdbm-*/
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
make install
cd /sources && rm -rf gdbm-*/
echo "<<< GDBM done"
