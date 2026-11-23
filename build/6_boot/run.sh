#!/bin/bash
# 6_boot/run.sh — Make the system bootable (LFS 12.4 ch. 9–10):
#   01 bootscripts, 02 /etc configuration, 03 kernel, 04 GRUB, 05 ft_check,
#   06 root password (INTERACTIVE, moved here from Shadow so ch. 8 runs unattended).
# Who/where: root INSIDE the chroot, after 5_final_system.
#
# Usage: bash $FT_DIR/build/6_boot/run.sh [--list | FROM [TO]]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
source "$HERE/../lib/steps.sh"

[ "${1:-}" = "--list" ] || ft_require_chroot

ft_run_steps "$HERE" "$@"
[ "${1:-}" = "--list" ] && exit 0

echo ""
echo "Next (same chroot):  bash \$FT_DIR/build/7_network/run.sh"
