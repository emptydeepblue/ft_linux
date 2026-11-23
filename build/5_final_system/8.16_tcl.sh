#!/bin/bash
# LFS 12.4 §8.16 — Tcl (needed by Expect and DejaGNU, i.e. by test suites)
set -euo pipefail
echo ">>> Tcl"
cd /sources
tar -xf tcl*-src.tar.gz
cd tcl8.*/

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath
make

# The *Config.sh files point to the build tree: make them point to /usr.
TDBC=$(basename "$(ls -d pkgs/tdbc1.* | head -1)")      # tdbc1.1.10
ITCL=$(basename "$(ls -d pkgs/itcl4.* | head -1)")      # itcl4.3.2
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/$TDBC|/usr/lib/$TDBC|" \
    -e "s|$SRCDIR/pkgs/$TDBC/generic|/usr/include|"  \
    -e "s|$SRCDIR/pkgs/$TDBC/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/$TDBC|/usr/include|"          \
    -i pkgs/$TDBC/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/$ITCL|/usr/lib/$ITCL|" \
    -e "s|$SRCDIR/pkgs/$ITCL/generic|/usr/include|"  \
    -e "s|$SRCDIR/pkgs/$ITCL|/usr/include|"          \
    -i pkgs/$ITCL/itclConfig.sh
unset SRCDIR TDBC ITCL

make install
chmod 644 /usr/lib/libtclstub8.6.a
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3     # name clash with a Perl man page

cd /sources && rm -rf tcl8.*/
echo "<<< Tcl done"
