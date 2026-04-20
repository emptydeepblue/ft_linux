#!/bin/bash
# Final system 38/79 — Inetutils
set -euo pipefail
echo ">>> Inetutils"
cd /sources
tar -xf inetutils-*.tar.xz
cd inetutils-*/
sed -i 's/support old/support_old/' configure   # fix for newer autoconf if needed || true
./configure --prefix=/usr         \
            --bindir=/usr/bin     \
            --localstatedir=/var  \
            --disable-logger      \
            --disable-whois       \
            --disable-rcp         \
            --disable-rexec       \
            --disable-rlogin      \
            --disable-rsh         \
            --disable-telnet      \
            --disable-servers
make
make install
mv -v /usr/{,s}bin/ifconfig 2>/dev/null || true
cd /sources && rm -rf inetutils-*/
echo "<<< Inetutils done"
