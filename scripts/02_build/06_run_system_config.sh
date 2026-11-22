#!/bin/bash
# 06_run_system_config.sh — Make the system bootable (LFS 12.4 ch. 9–10) and
# able to download (BLFS: CA certificates, wget, dhcpcd).
# Run INSIDE the chroot as root, after 05_run_final_system.sh.
#
# Usage:
#   bash /sources/ft_linux/scripts/02_build/06_run_system_config.sh     # all steps
#   bash /sources/ft_linux/scripts/02_build/06_run_system_config.sh 3   # resume from step 3
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYS_DIR="$SCRIPT_DIR/../03_system"

START="${1:-1}"

STEPS=(
    "01_bootscripts.sh:LFS-Bootscripts"
    "02_system_config.sh:/etc configuration (hostname, network, inittab, fstab...)"
    "03_kernel.sh:Linux kernel (10-20 min)"
    "04_grub.sh:GRUB bootloader"
    "05_libtasn1.sh:libtasn1 (BLFS)"
    "06_p11kit.sh:p11-kit (BLFS)"
    "07_make_ca.sh:make-ca — CA certificates (BLFS, needs network)"
    "08_wget.sh:Wget with HTTPS (BLFS)"
    "09_dhcpcd.sh:dhcpcd + service script (BLFS)"
)

echo "=== ft_linux System Configuration (ch. 9-10) ==="
echo "  Start step : $START / ${#STEPS[@]}"
echo "  MAKEFLAGS  : ${MAKEFLAGS:--j$(nproc)}"
echo ""

TOTAL_START=$(date +%s)

for i in "${!STEPS[@]}"; do
    step=$((i + 1))
    script="${STEPS[$i]%%:*}"
    name="${STEPS[$i]#*:}"

    if [ "$step" -lt "$START" ]; then
        echo "  [skip] $step/${#STEPS[@]} $name"
        continue
    fi

    echo "========================================"
    echo "  Step $step/${#STEPS[@]}: $name"
    echo "========================================"
    t0=$(date +%s)

    bash "$SYS_DIR/$script"

    elapsed=$(( $(date +%s) - t0 ))
    echo "  Completed in ${elapsed}s"
    echo ""
done

TOTAL=$(( $(date +%s) - TOTAL_START ))
echo "=== System configuration complete in ${TOTAL}s ==="
echo ""
echo "Next: exit the chroot, then on the host:"
echo "  sudo bash scripts/lfs_disk.sh detach   # before converting/booting the image"
