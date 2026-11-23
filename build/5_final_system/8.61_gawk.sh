#!/bin/bash
# LFS 12.4 §8.61 — Gawk
set -euo pipefail
echo ">>> Gawk"
cd /sources
tar -xf gawk-*.tar.xz
cd gawk-*/
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
rm -f /usr/bin/gawk-*          # an old versioned copy would make install fail
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
cd /sources && rm -rf gawk-*/
echo "<<< Gawk done"
