#!/bin/bash
# LFS 12.4 §8.20 — Binutils (final native build)
set -euo pipefail
echo ">>> Binutils"
cd /sources
tar -xf binutils-*.tar.xz
cd binutils-*/
mkdir -v build && cd build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu
make tooldir=/usr
make tooldir=/usr install
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/
cd /sources && rm -rf binutils-*/
echo "<<< Binutils done"
