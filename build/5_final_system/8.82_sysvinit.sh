#!/bin/bash
# LFS 12.4 §8.82 — Sysvinit
# The init system required by the subject (SysV).
set -euo pipefail
echo ">>> Sysvinit"
cd /sources
rm -rf sysvinit-*/            # leftovers of an interrupted run
tar -xf sysvinit-*.tar.xz
cd sysvinit-*/
patch -Np1 -i ../sysvinit-*-consolidated-1.patch
make
make install
cd /sources && rm -rf sysvinit-*/
echo "<<< Sysvinit done"
echo ""
echo "=== Final system build complete ==="
echo "Next: Chapter 9 — System Configuration"
