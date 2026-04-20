#!/bin/bash
# Final system 76/79 — Util-linux (final native build)
set -euo pipefail
echo ">>> Util-linux"
cd /sources
tar -xf util-linux-*.tar.xz
cd util-linux-*/
./configure --bindir=/usr/bin                             \
            --libdir=/usr/lib                             \
            --runstatedir=/run                            \
            --sbindir=/usr/sbin                           \
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
cd /sources && rm -rf util-linux-*/
echo "<<< Util-linux done"
