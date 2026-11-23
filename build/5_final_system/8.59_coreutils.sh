#!/bin/bash
# LFS 12.4 §8.59 — Coreutils
set -euo pipefail
echo ">>> Coreutils"
cd /sources
rm -rf coreutils-*/            # leftovers of an interrupted run
tar -xf coreutils-*.tar.xz
cd coreutils-*/
patch -Np1 -i ../coreutils-*-upstream_fix-1.patch
# i18n: multibyte characters in cut, fold, sort… (the patch touches the build system)
patch -Np1 -i ../coreutils-*-i18n-1.patch
autoreconf -fv
automake -af
# FORCE_UNSAFE_CONFIGURE: allow configure to run as root
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd /sources && rm -rf coreutils-*/
echo "<<< Coreutils done"
