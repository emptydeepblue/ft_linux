#!/bin/bash
# LFS 12.4 §8.48 — OpenSSL
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
mv -v /usr/share/doc/openssl /usr/share/doc/${PWD##*/}    # openssl-3.5.2
cp -vfr doc/* /usr/share/doc/${PWD##*/}
cd /sources && rm -rf openssl-*/
echo "<<< OpenSSL done"
