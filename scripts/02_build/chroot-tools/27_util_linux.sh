#!/bin/bash
# Chroot tools step 27/28 — Util-linux
# System utilities: mount, fdisk, login, etc.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Util-linux"

cd /sources
tar -xf util-linux-*.tar.xz
cd util-linux-*/

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib                             \
            --runstatedir=/run                            \
            --disable-chfn-chsh                           \
            --disable-login                               \
            --disable-nologin                             \
            --disable-su                                  \
            --disable-setpriv                             \
            --disable-runuser                             \
            --disable-pylibmount                          \
            --disable-static                              \
            --disable-liblastlog2                         \
            --without-python                              \
            ADJTIME_PATH=/var/lib/hwclock/adjtime         \
            --docdir=/usr/share/doc/util-linux-$(cat .tarball-version)

make
make install

cd /sources
rm -rf util-linux-*/

echo "<<< Util-linux done"
