#!/bin/bash
# LFS 12.4 §8.85 — Cleaning up: temporary files, libtool archives, and what is
# left of the cross-toolchain (x86_64-lfs-linux-gnu*).
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> Cleanup"
find /tmp -mindepth 1 -delete          # book: rm -rf /tmp/{*,.*}
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
# (book: userdel -r tester — this build never created the tester user)
echo "<<< Cleanup done"
