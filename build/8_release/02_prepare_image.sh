#!/bin/bash
# 02_prepare_image.sh — Make the finished system small before it becomes the
# evaluation disk.
# Who/where: root on the HOST, the chroot exited, the image mounted
# (sudo bash build/lfs_disk.sh mount), after a successful 01_boot_test.sh.
#
#   1. copy the build logs into the repo (logs/, not committed)
#   2. remove /sources (tarballs, scripts copy: ~600 MB not needed any more)
#   3. "make clean" in /usr/src/kernel-*: the sources stay (subject), the
#      object files go; .config and what external modules need are kept
#   4. empty /tmp
#   5. fill the free space with zeros, then delete it: the deleted files' old
#      blocks become zeros, which qemu-img skips when writing the .vdi
#
# Usage: sudo bash build/8_release/02_prepare_image.sh
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ft_require_root
ft_require_host
mountpoint -q "$LFS" && mountpoint -q "$LFS/boot" \
    || ft_die "$LFS and $LFS/boot must be mounted (sudo bash build/lfs_disk.sh mount)"
for d in dev proc sys run; do
    ! mountpoint -q "$LFS/$d" || ft_die "$LFS/$d is still mounted: exit the chroot, then sudo bash build/lfs_disk.sh umount && sudo bash build/lfs_disk.sh mount"
done
SRC="$LFS/usr/src/kernel-$KVER"
[ -f "$LFS/boot/vmlinuz-$KERNEL_RELEASE" ] || ft_die "no kernel in $LFS/boot: the build is not finished"

echo "This deletes $LFS/sources and the kernel object files in $SRC."
read -r -p "Type yes to continue: " answer
[ "$answer" = yes ] || { echo "Nothing done."; exit 0; }

echo "[1/5] Build logs -> $FT_ROOT/logs/"
if [ -d "$LFS/sources/logs" ]; then
    mkdir -p "$FT_ROOT/logs"
    cp -r "$LFS/sources/logs/." "$FT_ROOT/logs/"
    [ -n "${SUDO_USER:-}" ] && chown -R "$SUDO_USER:" "$FT_ROOT/logs"
fi

echo "[2/5] Removing $LFS/sources/*"
rm -rf "${LFS:?}"/sources/*

echo "[3/5] make clean in $SRC"
make -s -C "$SRC" clean
du -sh "$SRC"

echo "[4/5] Emptying /tmp"
find "$LFS/tmp" -mindepth 1 -delete

echo "[5/5] Zero-filling free space (ends with 'No space left on device': expected)"
for mp in "$LFS" "$LFS/boot"; do
    dd if=/dev/zero of="$mp/.zero" bs=1M status=none || true
    sync
    rm -f "$mp/.zero"
done
sync

echo ""
df -h "$LFS" "$LFS/boot"
echo ""
echo "Next: sudo bash build/lfs_disk.sh detach && sudo bash build/8_release/03_make_vdi.sh"
