#!/bin/bash
# Final system 13/79 — Tcl
set -euo pipefail
echo ">>> Tcl"
cd /sources
tar -xf tcl*-src.tar.gz
SRCDIR=$(pwd)/tcl8.*/
cd tcl8.*/

cd unix
./configure --prefix=/usr \
            --mandir=/usr/share/man
make

make install
chmod -v u+w /usr/lib/libtcl*.so
make install-private-headers
ln -sfv tclsh$(ls /usr/bin/tclsh* | grep -o '[0-9]\+\.[0-9]\+') /usr/bin/tclsh

# fix paths in config scripts
TCL_VER=$(ls /usr/lib/tclConfig.sh | xargs basename | sed 's/tclConfig.sh//')
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i /usr/lib/tclConfig.sh

cd /sources && rm -rf tcl*/
echo "<<< Tcl done"
