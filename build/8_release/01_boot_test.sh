#!/bin/bash
# 01_boot_test.sh — Boot the finished image in QEMU, like the school VM.
# Who/where: the build user on the HOST, no sudo (needs group kvm).
# The image must not be attached/mounted: sudo bash build/lfs_disk.sh detach
#
# Usage: bash build/8_release/01_boot_test.sh
#   then, from another terminal:
#   ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
#
# Same hardware as eval/02_create_vm.sh: BIOS, SATA/AHCI disk, e1000 NIC with
# NAT, ssh forwarded to 127.0.0.1:2222, clock in UTC. Two extras:
#   -snapshot      writes go to a temporary file: the image is NOT modified;
#   -cpu qemu64    a plain x86-64 CPU, not this PC's: anything compiled for the
#                  build machine's CPU would crash here ("Illegal instruction"),
#                  before reaching the school PC.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$FT_ROOT/build/lib/disk.sh"
ft_require_host
[ "$(id -u)" -ne 0 ] || echo "(note: root is not needed here)"
[ -r "$LFS_IMAGE" ] || ft_die "cannot read $LFS_IMAGE"
[ -z "$(ft_loop_of_image)" ] \
    || ft_die "the image is attached to a loop device: sudo bash build/lfs_disk.sh detach"

ACCEL=(-enable-kvm)
[ -w /dev/kvm ] || { echo "WARNING: no KVM access (group kvm?): very slow"; ACCEL=(); }

echo "=== Booting $LFS_IMAGE (snapshot: the image stays unchanged) ==="
exec qemu-system-x86_64 "${ACCEL[@]}" \
    -cpu qemu64 -smp 2 -m 2G \
    -drive file="$LFS_IMAGE",format=raw,if=none,id=disk \
    -device ahci,id=ahci -device ide-hd,drive=disk,bus=ahci.0 \
    -nic user,model=e1000,hostfwd=tcp:127.0.0.1:2222-:22 \
    -rtc base=utc \
    -snapshot
