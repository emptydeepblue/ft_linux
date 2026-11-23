#!/bin/bash
# LFS 12.4 §8.7 — Bzip2
set -euo pipefail
echo ">>> Bzip2"
cd /sources
tar -xf bzip2-*.tar.gz
cd bzip2-*/

# installs the docs where the book wants them
patch -Np1 -i ../bzip2-*-install_docs-1.patch

# fix symlink and man page paths
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

# build shared library first
make -f Makefile-libbz2_so
make clean

make
make PREFIX=/usr install

# install the shared library
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

# replace static bzip2 with shared-linked one
cp -v bzip2-shared /usr/bin/bzip2
for b in /usr/bin/{bzcat,bunzip2}; do ln -sfv bzip2 $b; done

rm -fv /usr/lib/libbz2.a
cd /sources && rm -rf bzip2-*/
echo "<<< Bzip2 done"
