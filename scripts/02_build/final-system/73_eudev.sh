#!/bin/bash
# Final system 73/79 — Eudev (udev without systemd)
# Subject requires Eudev as the kernel module loader.
set -euo pipefail
echo ">>> Eudev"
cd /sources
tar -xf eudev-*.tar.gz
cd eudev-*/

./configure --prefix=/usr           \
            --bindir=/usr/sbin       \
            --sbindir=/usr/sbin      \
            --sysconfdir=/etc        \
            --enable-manpages        \
            --disable-static

make

# prepare test infrastructure
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

make check
make install

# install udev-lfs boot scripts and rules
tar -xf ../udev-lfs-*.tar.xz
make -f udev-lfs-*/Makefile.lfs install

# build the hardware database
udevadm hwdb --update

cd /sources && rm -rf eudev-*/
echo "<<< Eudev done"
