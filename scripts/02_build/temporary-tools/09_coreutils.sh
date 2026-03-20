#!/bin/bash
# Temporary tools step 9/17 — Coreutils
# Basic file, shell, and text manipulation utilities (ls, cp, mv, etc.).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Coreutils"

cd "$LFS/sources"
tar -xf coreutils-*.tar.xz
cd coreutils-*/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

# chroot belongs in /usr/sbin, not /usr/bin
mv -v "$LFS/usr/bin/chroot" "$LFS/usr/sbin"
mkdir -pv "$LFS/usr/share/man/man8"
mv -v "$LFS/usr/share/man/man1/chroot.1" "$LFS/usr/share/man/man8/chroot.8"
sed -i 's/"1"/"8"/' "$LFS/usr/share/man/man8/chroot.8"

cd "$LFS/sources"
rm -rf coreutils-*/

echo "<<< Coreutils done"
