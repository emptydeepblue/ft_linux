#!/bin/bash
# Final system 33/79 — Bash
set -euo pipefail
echo ">>> Bash"
cd /sources
tar -xf bash-*.tar.gz
cd bash-*/
./configure --prefix=/usr              \
            --without-bash-malloc      \
            --with-installed-readline  \
            --docdir=/usr/share/doc/bash-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
make
make install
cd /sources && rm -rf bash-*/
echo "<<< Bash done"
echo "NOTE: run 'exec /usr/bin/bash --login' to reload the shell if needed"
