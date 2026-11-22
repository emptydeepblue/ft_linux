#!/bin/bash
# Chroot tools step 26/29 — Python (temporary, LFS 12.4 §7.10)
# Needed at build time by Glibc and other Ch.8 packages. The full Python
# (with libffi, expat, optimizations) is rebuilt in Ch.8 (§8.51).
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Python (temporary)"

cd /sources
tar -xf Python-*.tar.xz
cd Python-*/

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

# Warnings about modules that cannot be built (e.g. ssl) are expected here.
make
make install

cd /sources
rm -rf Python-*/

echo "<<< Python (temporary) done"
