#!/bin/bash
# Final system 15/79 — DejaGNU
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
VER=$(cat ../configure | grep 'PACKAGE_VERSION=' | head -1 | cut -d= -f2 | tr -d "'")
install -v -dm755 /usr/share/doc/dejagnu-${VER}
install -v -m644 doc/dejagnu.{txt,html} /usr/share/doc/dejagnu-${VER}
cd /sources && rm -rf dejagnu-*/
echo "<<< DejaGNU done"
