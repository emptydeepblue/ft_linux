#!/bin/bash
# 04_run_chroot_tools.sh — Build chroot temporary tools (steps 0, 23–28)
# Run INSIDE the chroot (after 03_enter_chroot.sh) as root.
#
# Usage:
#   bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh        # run all steps
#   bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh 3      # resume from step 3
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

START="${1:-1}"

STEPS=(
    "00_setup_dirs.sh:Initial directories and essential files"
    "23_gettext.sh:Gettext (temporary)"
    "24_bison.sh:Bison"
    "25_perl.sh:Perl"
    "26_texinfo.sh:Texinfo"
    "27_util_linux.sh:Util-linux"
    "28_cleanup.sh:Strip and clean"
)

echo "=== ft_linux Chroot Tools Builder ==="
echo "  Start step : $START / ${#STEPS[@]}"
echo "  MAKEFLAGS  : ${MAKEFLAGS:--j$(nproc)}"
echo ""

TOTAL_START=$(date +%s)

for i in "${!STEPS[@]}"; do
    step=$((i + 1))
    script="${STEPS[$i]%%:*}"
    name="${STEPS[$i]##*:}"

    if [ "$step" -lt "$START" ]; then
        echo "  [skip] $step/${#STEPS[@]} $name"
        continue
    fi

    echo "========================================"
    echo "  Step $step/${#STEPS[@]}: $name"
    echo "========================================"
    t0=$(date +%s)

    bash "$SCRIPT_DIR/$script"

    elapsed=$(( $(date +%s) - t0 ))
    echo "  Completed in ${elapsed}s"
    echo ""
done

TOTAL=$(( $(date +%s) - TOTAL_START ))
echo "=== Chroot tools complete in ${TOTAL}s ==="
echo ""
echo "Next: build the final system (Chapter 8)."
echo "  Continue inside this chroot — do not exit yet."
