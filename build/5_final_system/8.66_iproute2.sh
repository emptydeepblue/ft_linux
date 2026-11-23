#!/bin/bash
# LFS 12.4 §8.66 — IPRoute2
set -euo pipefail
echo ">>> IPRoute2"
cd /sources
rm -rf iproute2-*/            # leftovers of an interrupted run
tar -xf iproute2-*.tar.xz
cd iproute2-*/
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
cd /sources && rm -rf iproute2-*/
echo "<<< IPRoute2 done"
