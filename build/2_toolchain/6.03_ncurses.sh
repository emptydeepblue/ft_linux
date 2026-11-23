#!/bin/bash
# LFS 12.4 §6.3 — Ncurses
# Terminal handling library (needed by bash, less, vim…), cross-compiled.
# Run as lfs user.
set -euo pipefail

echo ">>> Ncurses"

cd "$LFS/sources"
tar -xf ncurses-*.tgz
cd ncurses-*/

# A tic that runs on the host, installed in $LFS/tools: make install uses it
# to compile the terminal database.
mkdir build
pushd build
    ../configure --prefix=$LFS/tools AWK=gawk
    make -C include
    make -C progs tic
    install progs/tic $LFS/tools/bin
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

make
make DESTDIR=$LFS install

# Programs that ask for -lncurses get the wide-character library
ln -sv libncursesw.so "$LFS/usr/lib/libncurses.so"
# Make curses.h always expose the wide-character definitions
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i "$LFS/usr/include/curses.h"

cd "$LFS/sources"
rm -rf ncurses-*/

echo "<<< Ncurses done"
