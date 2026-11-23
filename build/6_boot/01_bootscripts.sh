#!/bin/bash
# Boot step — LFS-Bootscripts (LFS 12.4 §9.2)
# SysV init scripts: /etc/rc.d/init.d/*, rc.site, the rc runlevel links.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> LFS-Bootscripts"
cd /sources
rm -rf lfs-bootscripts-*/            # leftovers of an interrupted run
tar -xf lfs-bootscripts-*.tar.xz
cd lfs-bootscripts-*/
make install
cd /sources && rm -rf lfs-bootscripts-*/
echo "<<< LFS-Bootscripts done"
