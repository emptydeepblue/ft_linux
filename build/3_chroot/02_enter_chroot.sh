#!/bin/bash
# 02_enter_chroot.sh — LFS 12.4 §7.3–7.4: mount the virtual kernel file
# systems and enter the chroot. Also refreshes the copy of the scripts.
# Who/where: root on the HOST. Repeatable: use it every time you (re)enter,
# e.g. after a WSL restart (first: sudo bash build/lfs_disk.sh mount).
#
# Usage: sudo bash build/3_chroot/02_enter_chroot.sh
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ft_require_root
ft_require_host
mountpoint -q "$LFS" || ft_die "$LFS is not mounted (sudo bash build/lfs_disk.sh mount)"
[ "$(stat -c %U "$LFS/usr")" = root ] \
    || ft_die "$LFS/usr is not owned by root: run build/3_chroot/01_chown_root.sh first"

echo "=== ft_linux — entering the chroot ($LFS) ==="

# ── §7.3 Virtual kernel file systems ─────────────────────────────────────────
mkdir -p "$LFS"/{dev,proc,sys,run}
mountpoint -q "$LFS/dev"     || mount -v --bind /dev "$LFS/dev"
mountpoint -q "$LFS/dev/pts" || mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
mountpoint -q "$LFS/proc"    || mount -vt proc proc "$LFS/proc"
mountpoint -q "$LFS/sys"     || mount -vt sysfs sysfs "$LFS/sys"
mountpoint -q "$LFS/run"     || mount -vt tmpfs tmpfs "$LFS/run"
if [ -h "$LFS/dev/shm" ]; then
    install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
    mountpoint -q "$LFS/dev/shm" || mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
fi

# ── Scripts + config, visible at /$FT_LFS_SUBDIR inside ──────────────────────
bash "$FT_ROOT/build/sync_to_lfs.sh"

# ── §7.4 Enter ───────────────────────────────────────────────────────────────
echo ""
echo "Inside the chroot, the phases are (each resumable, see --list):"
echo "  bash \$FT_DIR/build/4_chroot_tools/run.sh   # ch. 7"
echo "  bash \$FT_DIR/build/5_final_system/run.sh   # ch. 8"
echo "  bash \$FT_DIR/build/6_boot/run.sh           # ch. 9-10"
echo "  bash \$FT_DIR/build/7_network/run.sh        # BLFS"
echo ""

chroot "$LFS" /usr/bin/env -i      \
    HOME=/root                      \
    TERM="$TERM"                    \
    PS1='(lfs chroot) \u:\w\$ '     \
    PATH=/usr/bin:/usr/sbin         \
    MAKEFLAGS="-j$JOBS"             \
    TESTSUITEFLAGS="-j$JOBS"        \
    FT_DIR="/$FT_LFS_SUBDIR"        \
    /usr/bin/bash --login
