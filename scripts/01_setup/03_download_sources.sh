#!/bin/bash
# 03_download_sources.sh — Download and verify all LFS 12.2 SysV source packages
# Run as lfs user AFTER sourcing ~/.bash_profile
set -euo pipefail

LFS_VERSION="12.4"
BASE_URL="https://www.linuxfromscratch.org/lfs/downloads/$LFS_VERSION"

# ── Guards ───────────────────────────────────────────────────────────────────

if [ "$(whoami)" != "lfs" ]; then
    echo "ERROR: run as lfs user (sudo su - lfs)" >&2
    exit 1
fi

if [ -z "${LFS:-}" ]; then
    echo "ERROR: \$LFS is not set. Run: source ~/.bash_profile" >&2
    exit 1
fi

if ! mountpoint -q "$LFS"; then
    echo "ERROR: $LFS is not mounted." >&2
    exit 1
fi

SOURCES="$LFS/sources"
echo "=== LFS $LFS_VERSION Source Download ==="
echo "  Destination: $SOURCES"
echo ""

# ── wget-list ────────────────────────────────────────────────────────────────

cd "$SOURCES"

echo "[1/5] Fetching package list (wget-list-sysv)..."
wget -q --show-progress "$BASE_URL/wget-list-sysv" -O wget-list-sysv
echo "      Done."

# ── Main sources ─────────────────────────────────────────────────────────────

echo "[2/5] Downloading source packages (this will take a while)..."
wget --input-file=wget-list-sysv \
     --continue \
     --directory-prefix="$SOURCES" \
     2>&1 | tee wget_errors.log

# Show any failures
if grep -qi "ERROR\|failed\|404\|unable" wget_errors.log 2>/dev/null; then
    echo ""
    echo "WARNING: Some downloads may have failed. Check wget_errors.log"
fi
echo "      Done."

# ── Checksums ────────────────────────────────────────────────────────────────

echo "[3/5] Verifying checksums..."
wget -q "$BASE_URL/md5sums" -O md5sums
pushd "$SOURCES" > /dev/null

FAILED=$(md5sum -c md5sums 2>&1 | grep FAILED | wc -l)
if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "WARNING: $FAILED checksum(s) failed:"
    md5sum -c md5sums 2>&1 | grep FAILED
    echo ""
    echo "Re-download the failed files and re-run this script."
else
    echo "      All checksums OK."
fi
popd > /dev/null

# ── SysV-specific extras ─────────────────────────────────────────────────────

echo "[4/5] Downloading SysV-specific packages..."

# Check — unit testing framework (required for Glibc test suite)
wget -qc --show-progress \
    "https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz"

# Eudev — udev replacement for SysV (required for kernel module loading / device management)
wget -qc --show-progress \
    "https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz"
echo "      Done."

# ── Remove SystemD-only packages ─────────────────────────────────────────────

echo "[5/5] Removing SystemD-only packages (not needed for SysV)..."

rm -fv \
    dbus-*.tar.gz          \
    elfutils-*.tar.bz2     \
    flit_core-*.tar.gz     \
    jinja2-*.tar.gz        \
    libxcrypt-*.tar.xz     \
    markupsafe-*.tar.gz    \
    meson-*.tar.gz         \
    ninja-*.tar.gz         \
    openssl-*.tar.gz       \
    packaging-*.tar.gz     \
    python-*-docs-*.tar.bz2 \
    Python-*.tar.xz        \
    setuptools-*.tar.gz    \
    systemd-*.tar.gz       \
    systemd-man-pages-*.tar.xz \
    zstd-*.tar.gz          \
    2>/dev/null || true

echo "      Done."

# ── Cleanup ───────────────────────────────────────────────────────────────────

rm -f wget-list-sysv md5sums wget_errors.log

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "=== Summary ==="
echo "  Tarballs downloaded : $(ls "$SOURCES"/*.tar.* 2>/dev/null | wc -l)"
echo "  Disk used           : $(du -sh "$SOURCES" | cut -f1)"
echo ""

# Quick check for the 7 tarballs the cross-toolchain needs most
echo "Cross-toolchain tarballs check:"
for name in binutils gcc linux glibc mpfr gmp mpc; do
    f=$(ls "$SOURCES"/$name-*.tar.* 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        printf "  OK      : %s\n" "$(basename "$f")"
    else
        printf "  MISSING : %s\n" "$name"
    fi
done

echo ""
echo "Next: bash scripts/run_toolchain.sh"
