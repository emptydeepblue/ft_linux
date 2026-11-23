#!/bin/bash
# LFS 12.4 §8.21 — GMP (arbitrary precision arithmetic, needed by GCC)
set -euo pipefail
echo ">>> GMP"
cd /sources
rm -rf gmp-*/            # leftovers of an interrupted run
tar -xf gmp-*.tar.xz
cd gmp-*/

# GCC 15 rejects an old-style test program in configure (book fix)
sed -i '/long long t1;/,+1s/()/(...)/' configure

# Generic x86-64 code, not tuned for this CPU: the image must run on any PC.
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/${PWD##*/} \
            --host=none-linux-gnu
make
make html
make install
make install-html

cd /sources && rm -rf gmp-*/
echo "<<< GMP done"
