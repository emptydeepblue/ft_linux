#!/bin/bash
# LFS 12.4 §8.18 — DejaGNU
set -euo pipefail
echo ">>> DejaGNU"
cd /sources
tar -xf dejagnu-*.tar.gz
cd dejagnu-*/
mkdir build && cd build
../configure --prefix=/usr
makeinfo --plaintext -o doc/dejagnu.txt  ../doc/dejagnu.texi
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
make install
DOC=/usr/share/doc/$(basename "$(dirname "$PWD")")     # dejagnu-1.6.3
install -v -dm755 $DOC
install -v -m644  doc/dejagnu.{html,txt} $DOC
cd /sources && rm -rf dejagnu-*/
echo "<<< DejaGNU done"
