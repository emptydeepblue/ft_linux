#!/bin/bash
# LFS 12.4 §8.17 — Expect (needed by DejaGNU)
set -euo pipefail
echo ">>> Expect"

# Expect needs working PTYs: fail early if the chroot has none (/dev/pts).
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

cd /sources
rm -rf expect*/            # leftovers of an interrupted run
tar -xf expect*.tar.gz
cd expect*/
patch -Np1 -i ../expect-*-gcc15-1.patch
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make
make install
V=${PWD##*/expect}                                    # 5.45.4
ln -svf expect$V/libexpect$V.so /usr/lib

cd /sources && rm -rf expect*/
echo "<<< Expect done"
