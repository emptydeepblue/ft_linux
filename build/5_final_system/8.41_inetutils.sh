#!/bin/bash
# LFS 12.4 §8.41 — Inetutils
set -euo pipefail
echo ">>> Inetutils"
cd /sources
rm -rf inetutils-*/            # leftovers of an interrupted run
tar -xf inetutils-*.tar.xz
cd inetutils-*/
# Build fix for telnet with recent compilers (book)
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr         \
            --bindir=/usr/bin     \
            --localstatedir=/var  \
            --disable-logger      \
            --disable-whois       \
            --disable-rcp         \
            --disable-rexec       \
            --disable-rlogin      \
            --disable-rsh         \
            --disable-servers
make
make install
mv -v /usr/{,s}bin/ifconfig
cd /sources && rm -rf inetutils-*/
echo "<<< Inetutils done"
