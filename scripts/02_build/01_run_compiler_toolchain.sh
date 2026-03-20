#!/bin/bash
# run_toolchain.sh — Build the complete LFS cross-toolchain (steps 1–5)
# Run as lfs user after sourcing ~/.bash_profile
#
# Usage:
#   bash run_toolchain.sh          # run all 5 steps
#   bash run_toolchain.sh 3        # resume from step 3 (skip 1–2)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TC_DIR="$SCRIPT_DIR/compiler-toolchain"

START="${1:-1}"

STEPS=(
    "01_binutils.sh:Binutils (Pass 1)"
    "02_gcc.sh:GCC (Pass 1)"
    "03_linux_API.sh:Linux API Headers"
    "04_glibc.sh:Glibc"
    "05_libstdc.sh:Libstdc++ (Pass 1)"
)

# ── Pre-flight ────────────────────────────────────────────────────────────────

echo "=== ft_linux Cross-Toolchain Builder ==="
echo "  Start step : $START / ${#STEPS[@]}"
echo "  LFS        : ${LFS:-<not set>}"
echo "  LFS_TGT    : ${LFS_TGT:-<not set>}"
echo "  MAKEFLAGS  : ${MAKEFLAGS:-<not set>}"
echo ""

bash "$TC_DIR/00_check_env.sh" || {
    echo ""
    echo "Pre-flight check failed. Fix the errors above and retry."
    exit 1
}
echo ""

# ── Build loop ────────────────────────────────────────────────────────────────

TOTAL_START=$(date +%s)

for i in "${!STEPS[@]}"; do
    step=$((i + 1))
    script="${STEPS[$i]%%:*}"
    name="${STEPS[$i]##*:}"

    if [ "$step" -lt "$START" ]; then
        echo "  [skip] $step/$((${#STEPS[@]})) $name"
        continue
    fi

    echo "========================================"
    echo "  Step $step/${#STEPS[@]}: $name"
    echo "========================================"
    t0=$(date +%s)

    bash "$TC_DIR/$script"

    elapsed=$(( $(date +%s) - t0 ))
    echo "  Completed in ${elapsed}s"
    echo ""
done

TOTAL=$(( $(date +%s) - TOTAL_START ))
echo "=== Cross-toolchain complete in ${TOTAL}s ==="
echo ""
echo "Verify the cross-compiler works:"
echo "  echo 'int main(){}' | \$LFS_TGT-gcc -xc -"
echo "  readelf -l a.out | grep interpreter"
echo "  rm a.out"
echo ""
echo "Next phase: Cross-compile temporary tools (Chapter 6)"
echo "  cd \$LFS/sources && bash /path/to/06_temp_tools.sh"
