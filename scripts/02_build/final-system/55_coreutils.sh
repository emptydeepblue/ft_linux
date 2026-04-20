#!/bin/bash
# Final system 55/79 — Coreutils
set -euo pipefail
echo ">>> Coreutils"
cd /sources
tar -xf coreutils-*.tar.xz
cd coreutils-*/
# apply i18n patch if present
for p in ../coreutils-*-i18n-*.patch; do
    [ -f "$p" ] && patch -Np1 -i "$p" && autoreconf -fiv
done
FORCE_UNSAFE_CONFIGURE=1 ./configure \
    --prefix=/usr                     \
    --enable-no-install-program=kill,uptime \
    CFLAGS="-O2 -std=gnu17"
make
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd /sources && rm -rf coreutils-*/
echo "<<< Coreutils done"
