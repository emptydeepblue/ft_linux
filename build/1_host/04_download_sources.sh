#!/bin/bash
# 04_download_sources.sh — LFS 12.4 ch. 3: download and verify all the
# source packages (+ config/extra-sources.list) into $LFS/sources.
# Who/where: root on the HOST, after 03_disk_partition.sh.
#
# Usage: sudo bash build/1_host/04_download_sources.sh   (safe to re-run:
#        wget --continue skips what is already there)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

BASE_URL="https://www.linuxfromscratch.org/lfs/downloads/$LFS_VERSION"

# ── Guards ───────────────────────────────────────────────────────────────────

ft_require_root
ft_require_host
mountpoint -q "$LFS" || ft_die "$LFS is not mounted (sudo bash build/lfs_disk.sh mount)"

# §3.1: world-writable and sticky, like /tmp (the lfs user builds in here).
SOURCES="$LFS/sources"
mkdir -p "$SOURCES"
chmod a+wt "$SOURCES"
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

echo "[4/5] Downloading extra packages (config/extra-sources.list)..."

# Eudev, Check (subject) and the BLFS networking packages (make-ca, wget,
# dhcpcd...). Each line: URL MD5 ("-" = no published checksum).
EXTRA_FAILED=0
while read -r url md5; do
    case "$url" in ''|\#*) continue ;; esac
    file="$(basename "$url")"
    wget -qc --show-progress "$url" -O "$file" || { echo "      FAILED: $url"; EXTRA_FAILED=1; continue; }
    if [ "$md5" != "-" ] && ! echo "$md5  $file" | md5sum -c --quiet - ; then
        echo "      CHECKSUM FAILED: $file"; EXTRA_FAILED=1
    fi
done < "$FT_ROOT/config/extra-sources.list"
[ "$EXTRA_FAILED" -eq 0 ] && echo "      Done." || echo "      WARNING: some extra downloads failed (see above)."

# ── Remove SystemD-only packages ─────────────────────────────────────────────
# The SysV wget-list already excludes most systemd-specific packages; this is a
# belt-and-suspenders cleanup for the few that may slip in. Only packages that
# are NOT built anywhere under build/ are removed here — do not add
# zstd, libxcrypt, openssl, Python, meson, ninja, flit_core, markupsafe, jinja2
# or elfutils to this list: a SysV LFS build still needs them.

echo "[5/5] Removing SystemD-only packages (not used by a SysV build)..."

rm -fv \
    dbus-*.tar.*               \
    systemd-*.tar.*            \
    systemd-man-pages-*.tar.*  \
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
echo "Next: sudo bash build/1_host/05_lfs_user.sh"
