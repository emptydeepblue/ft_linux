#!/bin/bash
# 02_run_temporary_tools.sh — Cross-compile all temporary tools (steps 6–22)
# Run as lfs user after sourcing ~/.bash_profile
#
# Usage:
#   bash 02_run_temporary_tools.sh       # run all 17 steps
#   bash 02_run_temporary_tools.sh 3     # resume from step 3 (skip 1–2)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TT_DIR="$SCRIPT_DIR/temporary-tools"

START="${1:-1}"

STEPS=(
    "06_m4.sh:M4"
    "07_ncurses.sh:Ncurses"
    "08_bash.sh:Bash"
    "09_coreutils.sh:Coreutils"
    "10_diffutils.sh:Diffutils"
    "11_file.sh:File"
    "12_findutils.sh:Findutils"
    "13_gawk.sh:Gawk"
    "14_grep.sh:Grep"
    "15_gzip.sh:Gzip"
    "16_make.sh:Make"
    "17_patch.sh:Patch"
    "18_sed.sh:Sed"
    "19_tar.sh:Tar"
    "20_xz.sh:Xz"
    "21_binutils.sh:Binutils (Pass 2)"
    "22_gcc.sh:GCC (Pass 2)"
)

# ── Pre-flight ────────────────────────────────────────────────────────────────

echo "=== ft_linux Temporary Tools Builder ==="
echo "  Start step : $START / ${#STEPS[@]}"
echo "  LFS        : ${LFS:-<not set>}"
echo "  LFS_TGT    : ${LFS_TGT:-<not set>}"
echo "  MAKEFLAGS  : ${MAKEFLAGS:-<not set>}"
echo ""

if [ -z "${LFS:-}" ] || [ -z "${LFS_TGT:-}" ]; then
    echo "ERROR: LFS or LFS_TGT not set. Run: source ~/.bash_profile"
    exit 1
fi

# ── Build loop ────────────────────────────────────────────────────────────────

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

    bash "$TT_DIR/$script"

    elapsed=$(( $(date +%s) - t0 ))
    echo "  Completed in ${elapsed}s"
    echo ""
done

TOTAL=$(( $(date +%s) - TOTAL_START ))
echo "=== Temporary tools complete in ${TOTAL}s ==="
echo ""
echo "Next phase: Enter chroot and build additional temporary tools (Chapter 7)"
echo "  See build_notes/steps/build/08_chroot_setup.md"
