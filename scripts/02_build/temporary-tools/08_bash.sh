#!/bin/bash
# Temporary tools step 8/17 — Bash
# The shell used inside the chroot environment.
# Cross-compiled and installed to $LFS.
# Run as lfs user.
set -euo pipefail

echo ">>> Bash"

cd "$LFS/sources"
tar -xf bash-*.tar.gz
cd bash-*/

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc              \
            bash_cv_strtold_broken=no

make
make DESTDIR=$LFS install

# Provide /bin/sh symlink expected by scripts in chroot
ln -sv bash "$LFS/bin/sh"

cd "$LFS/sources"
rm -rf bash-*/

echo "<<< Bash done"
