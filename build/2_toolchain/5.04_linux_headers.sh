#!/bin/bash
# LFS 12.4 §5.4 — Linux API Headers
# Exposes the kernel's API to Glibc so it knows how to call the kernel.
# Run as lfs user.
set -euo pipefail

echo ">>> Linux API Headers"

mkdir -pv "$LFS/usr/include"

cd "$LFS/sources"
rm -rf linux-*/            # leftovers of an interrupted run
tar -xf linux-*.tar.xz
cd linux-*/

# Ensure no stale build artefacts from the source tarball
make mrproper

make headers
# Keep only .h files — other generated files are not needed
find usr/include -type f ! -name '*.h' -delete

cp -rv usr/include "$LFS/usr/"

cd "$LFS/sources"
rm -rf linux-*/

echo "<<< Linux API Headers done"
