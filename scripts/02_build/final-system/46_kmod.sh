#!/bin/bash
# Final system 46/79 — Kmod
set -euo pipefail
echo ">>> Kmod"
cd /sources
tar -xf kmod-*.tar.xz
cd kmod-*/
./configure --prefix=/usr     \
            --sysconfdir=/etc  \
            --with-openssl     \
            --with-xz          \
            --with-zstd        \
            --with-zlib        \
            --disable-manpages
make
make install
for t in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /usr/sbin/$t
done
ln -sfv kmod /usr/bin/lsmod
cd /sources && rm -rf kmod-*/
echo "<<< Kmod done"
