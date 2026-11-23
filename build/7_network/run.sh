#!/bin/bash
# 7_network/run.sh — Let ft_linux download over HTTPS (BLFS 12.4):
#   01 libtasn1, 02 p11-kit, 03 make-ca (CA certificates), 04 wget, 05 dhcpcd,
#   06 openssh (sshd started at boot).
# Who/where: root INSIDE the chroot, after 6_boot. Step 03 needs network.
#
# Usage: bash $FT_DIR/build/7_network/run.sh [--list | FROM [TO]]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
source "$HERE/../lib/steps.sh"

[ "${1:-}" = "--list" ] || ft_require_chroot

ft_run_steps "$HERE" "$@"
[ "${1:-}" = "--list" ] && exit 0

echo ""
echo "Build finished. Exit the chroot, then on the host:"
echo "  sudo bash build/lfs_disk.sh detach   # before converting/booting the image"
