#!/bin/bash
# 5_final_system/run.sh — Final system packages (LFS 12.4 ch. 8, §8.3–8.82).
# Who/where: root INSIDE the chroot.
#
# Usage: bash $FT_DIR/build/5_final_system/run.sh [--list | FROM [TO]]
#   e.g. run.sh 8.29      resume at GCC
#
# File names are book sections, so the order is the book's. Notes:
#   8.28 Shadow: the root password is set later, by 6_boot/06_root_password.sh.
#   8.29 GCC: the longest build (30–90 min).
#   8.58 Kmod 34 is Meson-only, so it comes after Ninja/Meson.
#   8.59a Check: not in the 12.4 book, kept because the subject lists it.
#   8.76 Eudev replaces the book's "Udev from Systemd" (subject requirement).
#   Glibc needs Python at build time: the temporary one from §7.10.
#   §8.84–8.85 (stripping, cleanup) are optional and not scripted.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
source "$HERE/../lib/steps.sh"

[ "${1:-}" = "--list" ] || ft_require_chroot

ft_run_steps "$HERE" "$@"
[ "${1:-}" = "--list" ] && exit 0

echo ""
echo "Next (same chroot):  bash \$FT_DIR/build/6_boot/run.sh"
