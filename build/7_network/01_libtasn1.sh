#!/bin/bash
# Network step — libtasn1 (BLFS 12.4) — ASN.1 library, needed by p11-kit.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> libtasn1"
cd /sources
rm -rf libtasn1-*/            # leftovers of an interrupted run
tar -xf libtasn1-*.tar.gz
cd libtasn1-*/
./configure --prefix=/usr --disable-static
make
make install
cd /sources && rm -rf libtasn1-*/
echo "<<< libtasn1 done"
