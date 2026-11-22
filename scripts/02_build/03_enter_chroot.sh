#!/bin/bash
# 03_enter_chroot.sh — Transfer ownership, mount VKFSs, and enter chroot
# Run as ROOT on the host AFTER the temporary tools are built.
#
# Usage:
#   sudo bash scripts/02_build/03_enter_chroot.sh
#
# Re-entering after reboot:
#   sudo bash scripts/02_build/03_enter_chroot.sh
#   (ownership is already root; mounts are lost on reboot so they are re-done)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: must run as root (sudo)."
    exit 1
fi

echo "=== ft_linux Chroot Entry ==="
echo "  LFS : $LFS"
echo ""

# ── 1. Transfer ownership ─────────────────────────────────────────────────────
# $LFS was owned by the lfs user during the toolchain build.
# All files must be owned by root before entering the final build.

echo "--- Transferring ownership to root ---"
chown -R root:root "$LFS"/{usr,lib,var,etc,bin,sbin,tools,sources} 2>/dev/null || true
[ -d "$LFS/lib64" ] && chown -R root:root "$LFS/lib64"
echo "  Done."
echo ""

# ── 2. Virtual kernel filesystems ────────────────────────────────────────────

echo "--- Mounting virtual kernel filesystems ---"

mkdir -pv "$LFS"/{dev,proc,sys,run}

# /dev — bind mount from host
mountpoint -q "$LFS/dev" || mount -v --bind /dev "$LFS/dev"

# /dev/pts
mountpoint -q "$LFS/dev/pts" || \
    mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"

# /proc
mountpoint -q "$LFS/proc" || mount -vt proc proc "$LFS/proc"

# /sys
mountpoint -q "$LFS/sys" || mount -vt sysfs sysfs "$LFS/sys"

# /run
mountpoint -q "$LFS/run" || mount -vt tmpfs tmpfs "$LFS/run"

# /dev/shm
if [ -h "$LFS/dev/shm" ]; then
    install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
    mountpoint -q "$LFS/dev/shm" || \
        mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
fi

echo "  Done."
echo ""

# ── 3. Copy scripts + config into the LFS filesystem ─────────────────────────
# Inside the chroot they are at /$FT_LFS_SUBDIR (same layout as the repo).
bash "$FT_ROOT/scripts/sync_to_lfs.sh"
echo ""

# ── 4. Enter chroot ──────────────────────────────────────────────────────────
echo "--- Entering chroot ---"
echo "  You are now inside the LFS environment."
echo "  Run: bash \$FT_DIR/scripts/02_build/04_run_chroot_tools.sh  (first entry)"
echo "   or: bash \$FT_DIR/scripts/02_build/05_run_final_system.sh"
echo ""

chroot "$LFS" /usr/bin/env -i        \
    HOME=/root                        \
    TERM="$TERM"                      \
    PS1='(lfs chroot) \u:\w\$ '      \
    PATH=/usr/bin:/usr/sbin           \
    MAKEFLAGS="-j$JOBS"               \
    FT_DIR="/$FT_LFS_SUBDIR"          \
    /usr/bin/bash --login
