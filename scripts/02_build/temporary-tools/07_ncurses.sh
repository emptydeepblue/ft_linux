#!/bin/bash
# Temporary tools step 7/17 — Ncurses
# Terminal handling library. Required by Bash, Less, Vim, and others.
# The host tic binary is built first (in a throwaway build dir) so the
# cross-compiled install can use it to process terminfo entries.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Ncurses"

cd "$LFS/sources"
tar -xf ncurses-*.tar.gz
cd ncurses-*/

# Build a native tic for the host (needed during make install)
sed -i s/mawk// configure
mkdir build
pushd build
    ../configure --disable-stripping
    make -C include
    make -C progs tic
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
            --disable-stripping

make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

# Provide the non-wide libncurses.so that many packages expect
ln -sv libncursesw.so "$LFS/usr/lib/libncurses.so"

# Fix curses.h so it exposes wide-character functions unconditionally
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i "$LFS/usr/include/curses.h"

cd "$LFS/sources"
rm -rf ncurses-*/

echo "<<< Ncurses done"
