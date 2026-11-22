#!/bin/bash
# 01_disk_partition.sh — Create, partition, format and mount the LFS disk.
# Run as root on the HOST.
#
# Usage:
#   sudo bash 01_disk_partition.sh            # target from config (LFS_DISK)
#   sudo bash 01_disk_partition.sh /dev/sdX   # force a block device
#
# Target (config/ft_linux.conf):
#   LFS_DISK empty -> image mode: creates the sparse file $LFS_IMAGE
#                     ($LFS_IMAGE_SIZE) and attaches it with losetup -fP.
#   LFS_DISK=/dev/sdX -> partitions that block device.
#
# Layout (MBR), kept in sync with VM_*_DEV in config/ft_linux.conf (fstab, grub.cfg) — inside
# the evaluation VM the disk is /dev/sda:
#   p1  $BOOT_MIB MiB  ext4  /boot
#   p2  rest           ext4  /
#   p3  $SWAP_MIB MiB  swap
#
# The host /etc/fstab is NOT modified. After a host/WSL restart use:
#   sudo bash scripts/lfs_disk.sh mount
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$FT_ROOT/scripts/lib/disk.sh"

[ $# -ge 1 ] && LFS_DISK="$1"

# ── Guards ───────────────────────────────────────────────────────────────────

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

if mountpoint -q "$LFS"; then
    echo "ERROR: $LFS is mounted. Unmount first: sudo bash $FT_ROOT/scripts/lfs_disk.sh detach" >&2
    exit 1
fi

echo "=== LFS Disk Setup ==="
if ft_image_mode; then
    echo "  Target : image file $LFS_IMAGE ($LFS_IMAGE_SIZE, sparse)"
    if [ -e "$LFS_IMAGE" ]; then
        echo "  WARNING: $LFS_IMAGE already exists and will be RECREATED (all data lost)."
    fi
else
    if [ ! -b "$LFS_DISK" ]; then
        echo "ERROR: $LFS_DISK is not a block device." >&2
        lsblk -d -o NAME,SIZE,TYPE,MODEL >&2
        exit 1
    fi
    if lsblk -nro MOUNTPOINTS "$LFS_DISK" | grep -q .; then
        echo "ERROR: $LFS_DISK (or one of its partitions) is mounted:" >&2
        lsblk -o NAME,SIZE,MOUNTPOINTS "$LFS_DISK" >&2
        exit 1
    fi
    echo "  Target : block device $LFS_DISK"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL "$LFS_DISK"
fi
echo "  LFS    : $LFS"
echo ""
echo "  Layout to create (MBR):"
echo "    p1  ${BOOT_MIB} MiB  ext4  -> $LFS/boot   (label lfs-boot)"
echo "    p2  rest       ext4  -> $LFS        (label lfs-root)"
echo "    p3  ${SWAP_MIB} MiB  swap                (label lfs-swap)"
echo ""
read -rp "ALL DATA ON THE TARGET WILL BE LOST. Type 'yes' to continue: " confirm
[ "$confirm" = "yes" ] || { echo "Aborted."; exit 0; }

# ── Create / attach ──────────────────────────────────────────────────────────

echo ""
echo "[1/4] Preparing target..."
if ft_image_mode; then
    old="$(ft_loop_of_image)"
    [ -n "$old" ] && losetup -d "$old"
    mkdir -p "$(dirname "$LFS_IMAGE")"
    rm -f "$LFS_IMAGE"
    truncate -s "$LFS_IMAGE_SIZE" "$LFS_IMAGE"
    DEV="$(losetup -fP --show "$LFS_IMAGE")"
    echo "      $LFS_IMAGE attached to $DEV"
else
    DEV="$LFS_DISK"
    wipefs -a "$DEV" > /dev/null
fi

# ── Partition ────────────────────────────────────────────────────────────────

echo "[2/4] Partitioning $DEV..."
DISK_MIB=$(( $(blockdev --getsize64 "$DEV") / 1024 / 1024 ))
ROOT_MIB=$(( DISK_MIB - BOOT_MIB - SWAP_MIB - 8 ))   # 8 MiB slack for alignment
if [ "$ROOT_MIB" -lt 10240 ]; then
    echo "ERROR: root partition would be only ${ROOT_MIB} MiB (< 10 GiB)." >&2
    exit 1
fi

sfdisk --quiet "$DEV" << EOF
label: dos

,${BOOT_MIB}M,83,*
,${ROOT_MIB}M,83
,,82
EOF

# Re-read the partition table and wait for the p1..p3 nodes.
blockdev --rereadpt "$DEV" 2>/dev/null || partx -u "$DEV" 2>/dev/null || true
udevadm settle 2>/dev/null || true
ft_wait_parts "$DEV"
echo "      Done."

# ── Format ───────────────────────────────────────────────────────────────────

echo "[3/4] Formatting partitions..."
mkfs.ext4 -q -F -L lfs-boot "$(ft_part "$DEV" 1)"
mkfs.ext4 -q -F -L lfs-root "$(ft_part "$DEV" 2)"
mkswap       -L lfs-swap "$(ft_part "$DEV" 3)" > /dev/null
echo "      Done."

# ── Mount ────────────────────────────────────────────────────────────────────

echo "[4/4] Mounting on $LFS..."
LFS_DISK="${LFS_DISK:-}" bash "$FT_ROOT/scripts/lfs_disk.sh" mount
echo "      Done."

# ── Verify ───────────────────────────────────────────────────────────────────

echo ""
echo "=== Verify ==="
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$DEV"
echo ""
df -h "$LFS" "$LFS/boot"
echo ""
echo "Disk ready. Next: sudo bash $FT_ROOT/scripts/01_setup/02_env_setup.sh"
echo "After a WSL/host restart: sudo bash $FT_ROOT/scripts/lfs_disk.sh mount"
