#!/bin/bash
# LFS 12.4 §8.51 — Python 3
set -euo pipefail
echo ">>> Python 3"
cd /sources
rm -rf Python-*/            # leftovers of an interrupted run
tar -xf Python-*.tar.xz
cd Python-*/
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations \
            --without-static-libpython
make
make install
cat > /etc/pip.conf << "EOF"
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
cd /sources && rm -rf Python-*/
echo "<<< Python 3 done"
