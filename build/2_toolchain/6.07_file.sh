#!/bin/bash
# LFS 12.4 §6.7 — File
# Determines the type of a file by examining its contents.
# A native build of the `file` binary is needed first so configure
# can run it on the host during the cross-compiled build.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> File"

cd "$LFS/sources"
tar -xf file-*.tar.gz
cd file-*/

# Build a native file binary (used by configure of the cross build)
mkdir build
pushd build
    ../configure --disable-bzlib      \
                 --disable-libseccomp \
                 --disable-xzlib      \
                 --disable-zlib
    make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

# .la files cause linker problems — remove them
rm -v "$LFS/usr/lib/libmagic.la"

cd "$LFS/sources"
rm -rf file-*/

echo "<<< File done"
