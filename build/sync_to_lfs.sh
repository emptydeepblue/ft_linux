#!/bin/bash
# sync_to_lfs.sh — Copy build/, config/ and eval/ into the LFS filesystem.
# Run as root on the HOST, whenever the scripts or the config change.
#
# Why: the repo lives in the builder's home, which is not readable by the
# lfs user (Ubuntu 22.04 homes are 0750) nor visible from the chroot. The copy
# at $LFS/sources/ft_linux is readable by both (/sources/ft_linux in chroot).
#
# Usage: sudo bash build/sync_to_lfs.sh
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

if [ -z "$LFS" ] || ! mountpoint -q "$LFS"; then
    echo "ERROR: LFS='$LFS' is not mounted." >&2
    exit 1
fi

if [ "$FT_LFS_DIR" = "$FT_ROOT" ]; then
    echo "Already running from $FT_LFS_DIR, nothing to sync."
    exit 0
fi

echo "--- Syncing $FT_ROOT -> $FT_LFS_DIR ---"
mkdir -p "$LFS/sources"
# Replace build/, config/, eval/ only: build logs may live next to them.
rm -rf "${FT_LFS_DIR:?}/build" "${FT_LFS_DIR:?}/config" "${FT_LFS_DIR:?}/eval"
mkdir -p "$FT_LFS_DIR"
cp -r "$FT_ROOT/build" "$FT_ROOT/config" "$FT_ROOT/eval" "$FT_LFS_DIR/"
chown -R root:root "$FT_LFS_DIR"
chmod -R u=rwX,go=rX "$FT_LFS_DIR"
find "$FT_LFS_DIR/build" -name '*.sh' -exec chmod 755 {} +
echo "  Done."
