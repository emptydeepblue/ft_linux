#!/bin/bash
# 03_make_vdi.sh — Turn the raw image into the evaluation disk ft_linux.vdi,
# write checksum.txt, and compress a copy for the GitHub Release.
# Who/where: root on the HOST, image detached (sudo bash build/lfs_disk.sh detach),
# after 02_prepare_image.sh.
#
#   ft_linux.vdi      dynamic VDI, header already in VirtualBox form; qemu-img
#                     does not write zero blocks, so it is already "compacted"
#                     (no VBoxManage --compact needed)
#   checksum.txt      shasum < ft_linux.vdi   (the subject's command), in the repo
#   ft_linux.vdi.xz   the same file compressed, to upload as a Release asset
#
# Never boot ft_linux.vdi attached normally afterwards: that changes it and
# breaks the checksum. Use eval/02_create_vm.sh (immutable disk).
#
# Usage: sudo bash build/8_release/03_make_vdi.sh [output-dir]   (default: /var/lib/ft_linux)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$FT_ROOT/build/lib/disk.sh"
ft_require_root
ft_require_host
[ -f "$LFS_IMAGE" ] || ft_die "$LFS_IMAGE not found"
[ -z "$(ft_loop_of_image)" ] || ft_die "the image is attached: sudo bash build/lfs_disk.sh detach"

OUT="${1:-$(dirname "$LFS_IMAGE")}"
VDI="$OUT/ft_linux.vdi"
mkdir -p "$OUT"
[ ! -e "$VDI" ] || ft_die "$VDI already exists: move it away first (it may be the submitted one)"

echo "[1/3] $LFS_IMAGE -> $VDI"
qemu-img convert -p -f raw -O vdi "$LFS_IMAGE" "$VDI"

# VirtualBox rewrites the header of a qemu-img VDI the first time it opens it,
# even attached immutable: cbHeader 384 -> 400 and LCHS cbSector 0 -> 512
# (offsets 72 and 468, little-endian; the data blocks are untouched).
# Write the same two fields now, so attaching the disk never changes its SHA-1.
printf '\x90\x01\x00\x00' | dd of="$VDI" bs=1 seek=72  conv=notrunc status=none
printf '\x00\x02\x00\x00' | dd of="$VDI" bs=1 seek=468 conv=notrunc status=none
qemu-img check -q -f vdi "$VDI" || ft_die "$VDI: header patch broke the image"

echo "[2/3] Checksum (shasum < ft_linux.vdi) -> $FT_ROOT/checksum.txt"
( cd "$OUT" && shasum < ft_linux.vdi ) | tee "$FT_ROOT/checksum.txt"

echo "[3/3] Compressing -> $VDI.xz (a few minutes)"
xz -k -T0 -6 "$VDI"

if [ -n "${SUDO_USER:-}" ]; then
    chown "$SUDO_USER:" "$FT_ROOT/checksum.txt" "$VDI" "$VDI.xz"
fi
echo ""
ls -lh "$VDI" "$VDI.xz"
echo ""
echo "Next: test it in VirtualBox (immutable): bash eval/02_create_vm.sh $VDI --start"
echo "      then commit checksum.txt and upload $VDI.xz as a GitHub Release asset."
