#!/bin/bash
# Final system 00 — Python Bootstrap (pre-Glibc)
#
# Glibc 2.39+ requires Python 3 at BUILD TIME to generate internal scripts.
# Python is officially step 49 but must exist before step 3 (Glibc).
# This script builds libffi + Python against the cross-compiled temporary Glibc.
# Both will be rebuilt again at their normal positions (48, 49) against the
# final native Glibc — so there is no harm in building them early.
set -euo pipefail

# ── Check: skip if python3 already works ──────────────────────────────────────
if python3 -c 'import sys; sys.exit(0)' 2>/dev/null; then
    echo ">>> Python bootstrap: python3 already available, skipping."
    exit 0
fi

echo ">>> Python Bootstrap — libffi"
cd /sources
tar -xf libffi-*.tar.gz 2>/dev/null || tar -xf libffi-*.tar.xz
cd libffi-*/
./configure --prefix=/usr --disable-static --with-gcc-arch=native
make
make install
cd /sources && rm -rf libffi-*/

echo ">>> Python Bootstrap — Expat (required by pyexpat module)"
cd /sources
tar -xf expat-*.tar.xz
cd expat-*/
./configure --prefix=/usr --disable-static
make
make install
cd /sources && rm -rf expat-*/

echo ">>> Python Bootstrap — Python 3"
cd /sources
rm -rf Python-*/
tar -xf Python-*.tar.xz
cd Python-*/
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --without-ensurepip
make
make install
cd /sources && rm -rf Python-*/

python3 --version
echo ">>> Python Bootstrap done — Glibc build can proceed."
