#!/bin/bash
# Final system 45/79 — OpenSSL
# Needed for wget/curl and secure network connectivity.
set -euo pipefail
echo ">>> OpenSSL"
cd /sources
tar -xf openssl-*.tar.gz
cd openssl-*/
./config --prefix=/usr          \
         --openssldir=/etc/ssl   \
         --libdir=lib            \
         shared                  \
         zlib-dynamic
make
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
VER=$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'" 2>/dev/null \
      || ls /usr/share/doc | grep openssl | head -1 | sed 's/openssl-//')
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-${VER} 2>/dev/null || true
cp -vfr doc/* /usr/share/doc/openssl-${VER} 2>/dev/null || true
cd /sources && rm -rf openssl-*/
echo "<<< OpenSSL done"
