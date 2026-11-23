#!/bin/bash
# 01_host_prepare.sh — Prepare an Ubuntu 22.04 host (WSL or VM) for the LFS build.
# Run as root on the HOST, once, before anything else.
#
#   1. apt: build tools required by LFS ch. 2.2 + tools for the disk image
#   2. /bin/sh -> bash, awk -> gawk, yacc -> bison
#   3. runs 02_version_check.sh and fails if it reports any ERROR
#
# Usage:
#   sudo bash build/1_host/01_host_prepare.sh            # everything
#   sudo bash build/1_host/01_host_prepare.sh --no-qemu  # skip QEMU (boot tests)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WITH_QEMU=1
for arg in "$@"; do
    case "$arg" in
        --no-qemu) WITH_QEMU=0 ;;
        -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
        *) echo "ERROR: unknown option '$arg'" >&2; exit 1 ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

. /etc/os-release
if [ "${ID:-}" != "ubuntu" ] || [ "${VERSION_ID:-}" != "22.04" ]; then
    echo "WARNING: tested on Ubuntu 22.04 only, this is ${PRETTY_NAME:-unknown}."
fi

echo "=== ft_linux host preparation ==="
echo ""

# ── 1. Packages ──────────────────────────────────────────────────────────────

PACKAGES=(
    # LFS ch. 2.2 host requirements
    build-essential bison gawk m4 texinfo patch perl python3
    coreutils diffutils findutils grep sed tar gzip bzip2 xz-utils file
    # downloading sources
    wget curl ca-certificates
    # disk / image handling
    util-linux fdisk parted e2fsprogs qemu-utils
)
[ "$WITH_QEMU" -eq 1 ] && PACKAGES+=(qemu-system-x86)

echo "[1/3] Installing packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends "${PACKAGES[@]}"
echo "      Done."

# ── 2. sh / awk / yacc ───────────────────────────────────────────────────────

echo "[2/3] Fixing tool aliases..."

# /bin/sh -> bash, the Debian way (survives dash upgrades).
if [ "$(readlink -f /bin/sh)" != "/usr/bin/bash" ]; then
    echo "dash dash/sh boolean false" | debconf-set-selections
    dpkg-reconfigure -f noninteractive dash
    # Fallback if the diversion did not happen for any reason.
    [ "$(readlink -f /bin/sh)" = "/usr/bin/bash" ] || ln -sfv bash /bin/sh
fi
echo "      sh   -> $(readlink -f /bin/sh)"

# awk -> gawk (Ubuntu defaults to mawk)
update-alternatives --set awk /usr/bin/gawk > /dev/null
echo "      awk  -> $(readlink -f /usr/bin/awk)"

# yacc -> bison (the Debian bison package ships bison.yacc as an alternative)
if [ -x /usr/bin/bison.yacc ]; then
    update-alternatives --install /usr/bin/yacc yacc /usr/bin/bison.yacc 100 > /dev/null
    update-alternatives --set yacc /usr/bin/bison.yacc > /dev/null
fi
echo "      yacc -> $(readlink -f /usr/bin/yacc 2>/dev/null || echo missing)"

# Let the invoking user run QEMU with KVM acceleration without sudo.
if [ "$WITH_QEMU" -eq 1 ] && [ -e /dev/kvm ] && getent group kvm > /dev/null \
   && [ -n "${SUDO_USER:-}" ] && ! id -nG "$SUDO_USER" | grep -qw kvm; then
    usermod -aG kvm "$SUDO_USER"
    echo "      added $SUDO_USER to group kvm (effective at next login)"
fi
echo "      Done."

# ── 3. Version check ─────────────────────────────────────────────────────────

echo "[3/3] Running LFS host version check..."
echo ""
REPORT="$(bash "$HERE/02_version_check.sh" 2>&1)" || true
echo "$REPORT" | sed 's/^/      /'
echo ""

if echo "$REPORT" | grep -qE '^(ERROR|FATAL)'; then
    echo "Host NOT ready: fix the ERROR lines above." >&2
    exit 1
fi

echo "Host ready for LFS $LFS_VERSION."
echo "Next: sudo bash $FT_ROOT/build/1_host/03_disk_partition.sh"
