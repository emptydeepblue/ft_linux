#!/bin/bash
# 01_disk_partition.sh — Partition, format, and mount the LFS disk
# Usage: sudo bash 01_disk_partition.sh [/dev/sdX]   (default: LFS_DISK in config)
# Run as root on the HOST system.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

DISK="${1:-$LFS_DISK}"

# ── Guards ───────────────────────────────────────────────────────────────────

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

if [ -z "$DISK" ]; then
    echo "ERROR: no disk given and LFS_DISK is empty in config/ft_linux.conf." >&2
    echo "  Pass a block device: sudo bash $0 /dev/sdX" >&2
    exit 1
fi

if [ ! -b "$DISK" ]; then
    echo "ERROR: $DISK is not a block device." >&2
    echo "  Available disks:" >&2
    lsblk -d -o NAME,SIZE,TYPE | grep disk >&2
    exit 1
fi

echo "=== LFS Disk Setup ==="
echo "  Disk : $DISK"
echo "  LFS  : $LFS"
echo ""
lsblk "$DISK"
echo ""
echo "  Layout to create:"
echo "    ${DISK}1  ${BOOT_MIB}M  ext4  → $LFS/boot   (boot partition)"
echo "    ${DISK}2  rest   ext4  → $LFS        (root filesystem)"
echo "    ${DISK}3  ${SWAP_MIB}M  swap                (swap)"
echo ""
read -rp "Partition $DISK? ALL DATA WILL BE LOST. Type 'yes' to continue: " confirm
[ "$confirm" = "yes" ] || { echo "Aborted."; exit 0; }

# ── Partition ────────────────────────────────────────────────────────────────

echo ""
echo "[1/4] Partitioning $DISK..."

# Wipe any existing partition table
wipefs -a "$DISK" &>/dev/null || true

# Layout: p1 /boot (512M) · p2 / root (fills the disk minus swap) · p3 swap (~2G).
# Partition numbers are kept in sync with config/fstab and config/grub.cfg:
#   /dev/sdaN 1 = /boot, 2 = /, 3 = swap  (inside the VM the disk is /dev/sda).
# BOOT_MIB and SWAP_MIB come from config/ft_linux.conf.
DISK_MIB=$(( $(blockdev --getsize64 "$DISK") / 1024 / 1024 ))
ROOT_MIB=$(( DISK_MIB - BOOT_MIB - SWAP_MIB - 8 ))   # 8 MiB slack for alignment

sfdisk --quiet "$DISK" << EOF
label: dos

,${BOOT_MIB}M,83
,${ROOT_MIB}M,83
,,82
EOF

# Give the kernel time to re-read the partition table
partprobe "$DISK" 2>/dev/null || true
sleep 1

echo "      Done."

# ── Format ───────────────────────────────────────────────────────────────────

echo "[2/4] Formatting partitions..."
mkfs.ext4 -F -L "lfs-boot" "${DISK}1"
mkfs.ext4 -F -L "lfs-root" "${DISK}2"
mkswap    -L "lfs-swap"    "${DISK}3"
echo "      Done."

# ── Mount ────────────────────────────────────────────────────────────────────

echo "[3/4] Mounting to $LFS..."
mkdir -pv "$LFS"
mount -v -t ext4 "${DISK}2" "$LFS"
mkdir -pv "$LFS/boot"
mount -v -t ext4 "${DISK}1" "$LFS/boot"
swapon -v "${DISK}3"
echo "      Done."

# ── /etc/fstab ───────────────────────────────────────────────────────────────

echo "[4/4] Adding LFS entries to /etc/fstab..."

if grep -q "lfs-root\|${DISK}2" /etc/fstab 2>/dev/null; then
    echo "      Entries already present in /etc/fstab, skipping."
else
    cat >> /etc/fstab << EOF

# LFS partitions ($DISK) — added by 01_disk_partition.sh
LABEL=lfs-root  $LFS       ext4  defaults  0  2
LABEL=lfs-boot  $LFS/boot  ext4  defaults  0  2
LABEL=lfs-swap  none       swap  sw        0  0
EOF
    echo "      Done."
fi

# ── Verify ───────────────────────────────────────────────────────────────────

echo ""
echo "=== Verify ==="
lsblk "$DISK"
echo ""
mount | grep lfs
swapon --show
echo ""
df -h "$LFS" "$LFS/boot"
echo ""
echo "Disk ready. Next: sudo bash $FT_ROOT/scripts/01_setup/02_env_setup.sh"
