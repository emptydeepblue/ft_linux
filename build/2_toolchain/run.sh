#!/bin/bash
# 2_toolchain/run.sh — Cross-toolchain (LFS ch. 5) and temporary tools (ch. 6).
# Who/where: user lfs on the HOST (sudo su - lfs). Writes only inside $LFS.
#
# Usage: bash $FT_DIR/build/2_toolchain/run.sh [--list | FROM [TO]]
#   no args = all steps; FROM/TO = book section or step number (see lib/steps.sh)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
source "$HERE/../lib/steps.sh"

if [ "${1:-}" != "--list" ]; then
    ft_require_user lfs
    bash "$HERE/check_env.sh" || ft_die "pre-flight check failed (see above)"
fi

ft_run_steps "$HERE" "$@"
[ "${1:-}" = "--list" ] && exit 0

echo ""
echo "Check the toolchain (book §5.5):  echo 'int main(){}' | $LFS_TGT-gcc -xc - && readelf -l a.out | grep interpreter"
echo "Next (as root on the host, exit the lfs shell first):"
echo "  sudo bash build/3_chroot/01_chown_root.sh"
