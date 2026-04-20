#!/bin/bash
# Final system 77/79 — E2fsprogs
set -euo pipefail
echo ">>> E2fsprogs"
cd /sources
tar -xf e2fsprogs-*.tar.gz
cd e2fsprogs-*/
mkdir -v build && cd build
../configure --prefix=/usr           \
             --sysconfdir=/etc        \
             --enable-elf-shlibs      \
             --disable-libblkid       \
             --disable-libuuid        \
             --disable-uuidd          \
             --disable-fsck
make
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
cd /sources && rm -rf e2fsprogs-*/
echo "<<< E2fsprogs done"
