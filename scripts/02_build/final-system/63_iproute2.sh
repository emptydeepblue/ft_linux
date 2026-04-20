#!/bin/bash
# Final system 63/79 — IPRoute2
set -euo pipefail
echo ">>> IPRoute2"
cd /sources
tar -xf iproute2-*.tar.xz
cd iproute2-*/
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
cd /sources && rm -rf iproute2-*/
echo "<<< IPRoute2 done"
