#!/bin/bash
# 4_chroot_tools/run.sh — Directories, essential files and extra temporary tools (LFS ch. 7.5–7.13).
# Who/where: root INSIDE the chroot (build/3_chroot/02_enter_chroot.sh).
#
# Usage: bash $FT_DIR/build/4_chroot_tools/run.sh [--list | FROM [TO]]
#   no args = all steps; FROM/TO = book section or step number (see lib/steps.sh)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
source "$HERE/../lib/steps.sh"

if [ "${1:-}" != "--list" ]; then
    ft_require_chroot
fi

ft_run_steps "$HERE" "$@"
[ "${1:-}" = "--list" ] && exit 0

echo ""
echo "Next (same chroot):  bash $FT_DIR/build/5_final_system/run.sh"
