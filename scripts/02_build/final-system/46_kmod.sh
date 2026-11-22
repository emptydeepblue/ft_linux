#!/bin/bash
# Final system — Kmod (LFS 12.4 §8.58). Kmod 34 builds with Meson only,
# so it runs after Ninja/Meson. Meson installs the depmod/insmod/lsmod/
# modinfo/modprobe/rmmod links itself; zstd/xz/zlib/openssl are autodetected.
set -euo pipefail
echo ">>> Kmod"
cd /sources
tar -xf kmod-*.tar.xz
cd kmod-*/
mkdir -p build
cd       build
meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false
ninja
ninja install
cd /sources && rm -rf kmod-*/
echo "<<< Kmod done"
