#!/bin/bash
# LFS 12.4 §8.76 (replaces "Udev from Systemd") — Eudev, udev without systemd.
# The device manager: creates /dev entries and loads kernel modules for the
# hardware it finds (with Kmod, the subject's "kernel module loader").
# Reference: LFS 9.1 §6.76 (the last book with Eudev), adapted to the merged
# /usr layout: with --prefix=/usr, eudev's defaults already put the rules in
# /usr/lib/udev/rules.d and the libraries in /usr/lib.
set -euo pipefail
echo ">>> Eudev"
cd /sources
rm -rf eudev-*/            # leftovers of an interrupted run
tar -xf eudev-*.tar.gz
cd eudev-*/

./configure --prefix=/usr           \
            --bindir=/usr/sbin      \
            --sbindir=/usr/sbin     \
            --sysconfdir=/etc       \
            --enable-manpages       \
            --disable-static
make
mkdir -pv /usr/lib/udev/rules.d /etc/udev/rules.d
make install
# (make check skipped: this build does not run test suites)

# lfs-bootscripts call /sbin/udevd (= /usr/sbin/udevd, installed by eudev) and
# /bin/udevadm (= /usr/bin/udevadm): eudev puts udevadm in /usr/sbin.
ln -sfv ../sbin/udevadm /usr/bin/udevadm

# Subject item "Udev-lfs Tarball": LFS rules (55-lfs.rules: set the clock when
# the RTC appears) and the scripts that write persistent network names.
tar -xf ../udev-lfs-*.tar.xz
make -f udev-lfs-*/Makefile.lfs install

# Hardware database (USB/PCI ids → names, keyboard quirks…)
udevadm hwdb --update

cd /sources && rm -rf eudev-*/
echo "<<< Eudev done"
