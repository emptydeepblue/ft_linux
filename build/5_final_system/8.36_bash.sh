#!/bin/bash
# LFS 12.4 §8.36 — Bash
set -euo pipefail
echo ">>> Bash"
cd /sources
rm -rf bash-*/            # leftovers of an interrupted run
tar -xf bash-*.tar.gz
cd bash-*/
./configure --prefix=/usr              \
            --without-bash-malloc      \
            --with-installed-readline  \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install
cd /sources && rm -rf bash-*/
echo "<<< Bash done"
echo "NOTE: run 'exec /usr/bin/bash --login' to reload the shell if needed"
