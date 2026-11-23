#!/bin/bash
# 04_download_sources.sh — LFS 12.4 ch. 3: download and verify all the
# source packages (+ config/extra-sources.list) into $LFS/sources.
# Who/where: root on the HOST, after 03_disk_partition.sh.
#
# Usage: sudo bash build/1_host/04_download_sources.sh   (safe to re-run:
#        wget --continue skips what is already there)
#
# Upstream URLs of the book sometimes disappear (e.g. ncurses snapshots are
# removed from ".../ncurses/current/"). Every official file that is missing or
# has a wrong md5 is fetched again from $LFS_MIRROR, the LFS package archive
# that keeps every file of every release. The script fails at the end if any
# file is still missing or wrong, so the build never starts without it.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

BASE_URL="https://www.linuxfromscratch.org/lfs/downloads/$LFS_VERSION"

ft_require_root
ft_require_host
mountpoint -q "$LFS" || ft_die "$LFS is not mounted (sudo bash build/lfs_disk.sh mount)"

# §3.1: world-writable and sticky, like /tmp (the lfs user builds in here).
SOURCES="$LFS/sources"
mkdir -p "$SOURCES"
chmod a+wt "$SOURCES"
cd "$SOURCES"

echo "=== LFS $LFS_VERSION source download ==="
echo "  Destination: $SOURCES"
echo "  Fallback   : $LFS_MIRROR"
echo ""

# ── 1. Lists ─────────────────────────────────────────────────────────────────
echo "[1/5] Package list and checksums of the book..."
wget -q "$BASE_URL/wget-list-sysv" -O wget-list-sysv
wget -q "$BASE_URL/md5sums"        -O md5sums
# systemd and D-Bus are listed for the book's systemd edition: not downloaded.
# (Do not add anything built by build/: zstd, openssl, Python, meson…)
sed -i -E '/\/(systemd|systemd-man-pages|dbus)-[0-9]/d' wget-list-sysv
sed -i -E '/  (systemd|systemd-man-pages|dbus)-[0-9]/d'  md5sums
echo "      $(wc -l < wget-list-sysv) files listed (systemd, D-Bus skipped)."

# ── 2. Official sources ──────────────────────────────────────────────────────
# A failing URL must not stop the script (wget exits non-zero, and pipefail
# would end everything here): failures are handled in step 3.
echo "[2/5] Downloading the book's packages (a few minutes)..."
wget --input-file=wget-list-sysv --continue --directory-prefix="$SOURCES" \
     --no-verbose 2>&1 | tee wget.log || true

# ── 3. Checksums, fallback mirror for what is missing or wrong ──────────────
echo "[3/5] Verifying checksums..."
# md5sum -c exits 1 when a file is bad — exactly the case handled here, so its
# status must not stop the script (set -e + pipefail).
bad_files() { { md5sum -c md5sums 2>/dev/null || true; } | awk -F': ' '$2 != "OK" {print $1}'; }
BAD="$(bad_files)"
if [ -n "$BAD" ]; then
    echo "      Missing or wrong from upstream, retrying from the LFS mirror:"
    for f in $BAD; do
        echo "        $f"
        rm -f "$f"
        wget -q "$LFS_MIRROR/$f" -O "$f" || rm -f "$f"
    done
    BAD="$(bad_files)"
fi
[ -z "$BAD" ] && echo "      All $(wc -l < md5sums) checksums OK."

# ── 4. Extra packages (not in the book's list) ──────────────────────────────
# Eudev, Check (subject) and the BLFS networking packages. Each line of
# config/extra-sources.list: URL MD5 ("-" = no published checksum).
echo "[4/5] Extra packages (config/extra-sources.list)..."
EXTRA_BAD=""
while read -r url md5; do
    case "$url" in ''|\#*) continue ;; esac
    f="$(basename "$url")"
    if ! wget -q -c "$url" -O "$f"; then
        rm -f "$f"; EXTRA_BAD+=" $f(download)"; continue
    fi
    if [ "$md5" != "-" ] && ! echo "$md5  $f" | md5sum -c --quiet - 2>/dev/null; then
        EXTRA_BAD+=" $f(md5)"
    fi
done < "$FT_ROOT/config/extra-sources.list"
[ -z "$EXTRA_BAD" ] && echo "      All extra packages OK."

# ── 5. Clean up ─────────────────────────────────────────────────────────────
echo "[5/5] Cleaning up (and removing systemd/D-Bus tarballs of older runs)..."
rm -fv dbus-[0-9]*.tar.* systemd-[0-9]*.tar.* systemd-man-pages-*.tar.*
rm -f wget-list-sysv md5sums wget.log wget_errors.log

# ── Result ───────────────────────────────────────────────────────────────────
echo ""
echo "=== $(ls "$SOURCES" | wc -l) files, $(du -sh "$SOURCES" | cut -f1) in $SOURCES ==="
if [ -n "$BAD" ] || [ -n "$EXTRA_BAD" ]; then
    [ -n "$BAD" ]       && echo "STILL MISSING OR WRONG (book):$(printf ' %s' $BAD)" >&2
    [ -n "$EXTRA_BAD" ] && echo "STILL MISSING OR WRONG (extra):$EXTRA_BAD" >&2
    ft_die "some sources are not usable: fix the URLs, then run this script again"
fi
echo "All sources present and verified."
echo ""
echo "Next: sudo bash build/1_host/05_lfs_user.sh"
