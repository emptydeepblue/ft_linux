#!/bin/bash
# Temporary tools step 10/17 — Diffutils
# File comparison utilities (diff, cmp, etc.).
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Diffutils"

cd "$LFS/sources"
tar -xf diffutils-*.tar.xz
cd diffutils-*/

./configure --prefix=/usr                       \
            --host=$LFS_TGT                     \
            --build=$(./build-aux/config.guess) \
            ac_cv_func_strcasecmp=yes           \
            gl_cv_func_strcasecmp_works=yes

make
make DESTDIR=$LFS install

cd "$LFS/sources"
rm -rf diffutils-*/

echo "<<< Diffutils done"
