#!/bin/bash
# LFS 12.4 §7.13 — Cleaning up the temporary system.
# Removes what the final system does not need: documentation, libtool .la
# files (they would point later builds at wrong paths) and the cross-toolchain
# in /tools, which is never used again.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Cleanup"

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools

echo "<<< Cleanup done"
