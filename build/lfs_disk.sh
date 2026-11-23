#!/bin/bash
# lfs_disk.sh — Attach/mount, unmount and detach the LFS target disk.
# Run as root on the HOST. Needed after every WSL/host restart, because loop
# devices and mounts do not survive it (the image file does).
#
# Usage: sudo bash build/lfs_disk.sh <command>
#   mount    attach the image (image mode) and mount p2 on $LFS, p1 on $LFS/boot
#   umount   unmount $LFS recursively (also /dev, /proc, ... of a chroot)
#   detach   umount + release the loop device (image mode)
#   status   show loop device, partitions and mounts
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$FT_ROOT/build/lib/disk.sh"

usage() { sed -n '6,10p' "$0"; exit "${1:-0}"; }

[ $# -eq 1 ] || usage 1
case "$1" in
    mount|umount|detach|status) ;;
    -h|--help) usage 0 ;;
    *) usage 1 ;;
esac
if [ "$(id -u)" -ne 0 ] && [ "$1" != "status" ]; then
    echo "ERROR: run as root (sudo bash $0 $1)" >&2
    exit 1
fi

do_mount() {
    local dev
    dev="$(ft_target_dev)"
    ft_wait_parts "$dev"
    mkdir -p "$LFS"
    mountpoint -q "$LFS"      || mount -v -t ext4 "$(ft_part "$dev" 2)" "$LFS"
    mkdir -p "$LFS/boot"
    mountpoint -q "$LFS/boot" || mount -v -t ext4 "$(ft_part "$dev" 1)" "$LFS/boot"
    echo "Mounted: $(ft_part "$dev" 2) -> $LFS, $(ft_part "$dev" 1) -> $LFS/boot"
}

do_umount() {
    if mountpoint -q "$LFS"; then
        sync
        umount -v -R "$LFS"
    else
        echo "$LFS is not mounted."
    fi
}

do_detach() {
    do_umount
    if ft_image_mode; then
        local dev
        dev="$(ft_loop_of_image)"
        if [ -n "$dev" ]; then
            losetup -d "$dev"
            echo "Detached $dev ($LFS_IMAGE)."
        else
            echo "Image not attached."
        fi
    fi
}

do_status() {
    local dev=""
    if ft_image_mode; then
        echo "Mode  : image $LFS_IMAGE ($( [ -f "$LFS_IMAGE" ] && du -h --apparent-size "$LFS_IMAGE" | cut -f1 || echo missing ), $( [ -f "$LFS_IMAGE" ] && du -h "$LFS_IMAGE" | cut -f1 || echo 0 ) used)"
        dev="$(ft_loop_of_image)"
        echo "Loop  : ${dev:-not attached}"
    else
        dev="$LFS_DISK"
        echo "Mode  : block device $dev"
    fi
    [ -n "$dev" ] && [ -b "$dev" ] && lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$dev"
    echo "Mounts:"
    findmnt -R "$LFS" || echo "  $LFS not mounted"
}

case "$1" in
    mount)  do_mount  ;;
    umount) do_umount ;;
    detach) do_detach ;;
    status) do_status ;;
    -h|--help) usage 0 ;;
    *) usage 1 ;;
esac
