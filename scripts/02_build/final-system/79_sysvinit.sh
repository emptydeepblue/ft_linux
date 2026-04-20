#!/bin/bash
# Final system 79/79 — Sysvinit
# The init system required by the subject (SysV).
set -euo pipefail
echo ">>> Sysvinit"
cd /sources
tar -xf sysvinit-*.tar.xz
cd sysvinit-*/
# apply sysvinit-*.patch if present
for p in ../sysvinit-*-consolidated-*.patch; do
    [ -f "$p" ] && patch -Np1 -i "$p"
done
make
make install
cd /sources && rm -rf sysvinit-*/
echo "<<< Sysvinit done"
echo ""
echo "=== Final system build complete ==="
echo "Next: Chapter 9 — System Configuration"
