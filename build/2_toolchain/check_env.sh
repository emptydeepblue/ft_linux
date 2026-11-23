#!/bin/bash
# check_env.sh — Pre-flight check of the lfs build environment (not a step:
# run.sh calls it before building). Who/where: user lfs on the HOST.
# Exit 0 = all good, exit 1 = problems found

# Remember whether LFS came from the lfs environment before the config fills it.
LFS_FROM_ENV="${LFS:-}"
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

PASS=0
FAIL=0

ok()   { printf "  OK:    %s\n" "$1"; ((PASS++)); }
fail() { printf "  ERROR: %s\n" "$1"; ((FAIL++)); }

echo "=== Cross-Toolchain Pre-flight Check ==="

# ── User ─────────────────────────────────────────────────────────────────────

echo ""
echo "--- User ---"
if [ "$(whoami)" = "lfs" ]; then
    ok "Running as lfs user"
else
    fail "Not lfs user — run: sudo su - lfs"
fi

# ── Environment ──────────────────────────────────────────────────────────────

echo ""
echo "--- Environment ---"

if [ -z "$LFS_FROM_ENV" ]; then
    fail "LFS not set — run: source ~/.bash_profile"
elif [ "$LFS_FROM_ENV" != "$LFS" ]; then
    fail "LFS=$LFS_FROM_ENV differs from config ($LFS)"
else
    ok "LFS=$LFS"
fi

if [ -n "${LFS_TGT:-}" ]; then
    ok "LFS_TGT=$LFS_TGT"
else
    fail "LFS_TGT not set"
fi

if echo "$PATH" | grep -q "$LFS/tools/bin"; then
    ok "PATH has \$LFS/tools/bin first"
else
    fail "PATH missing \$LFS/tools/bin — source ~/.bash_profile"
fi

if [ -n "${MAKEFLAGS:-}" ]; then
    ok "MAKEFLAGS=$MAKEFLAGS"
else
    fail "MAKEFLAGS not set (parallel builds disabled)"
fi

# ── Mounts & disk ────────────────────────────────────────────────────────────

echo ""
echo "--- Mounts & disk ---"

if mountpoint -q "$LFS" 2>/dev/null; then
    ok "$LFS is mounted"
else
    fail "$LFS is not mounted — run: sudo bash build/lfs_disk.sh mount"
fi

if mountpoint -q "$LFS/boot" 2>/dev/null; then
    ok "$LFS/boot is mounted"
else
    fail "$LFS/boot is not mounted"
fi

avail=$(df -BG "$LFS" 2>/dev/null | awk 'NR==2{gsub(/G/,"",$4); print $4}')
if [ "${avail:-0}" -gt 10 ]; then
    ok "Disk space: ${avail}G free on $LFS"
else
    fail "Low disk space: only ${avail:-?}G free on $LFS (need > 10G)"
fi

# ── Directory structure ───────────────────────────────────────────────────────

echo ""
echo "--- Directory structure ---"

for d in tools sources usr/bin usr/lib usr/sbin lib; do
    if [ -d "$LFS/$d" ]; then
        ok "$LFS/$d"
    else
        fail "$LFS/$d missing — run: sudo bash build/1_host/05_lfs_user.sh"
    fi
done

# lfs must be able to write where it builds and installs (§4.3)
for d in tools usr etc var sources; do
    if [ -w "$LFS/$d" ]; then
        ok "$LFS/$d writable by $(whoami)"
    else
        fail "$LFS/$d not writable — run: sudo bash build/1_host/05_lfs_user.sh"
    fi
done

# ── Required source tarballs ─────────────────────────────────────────────────

echo ""
echo "--- Required tarballs in \$LFS/sources ---"

SOURCES="$LFS/sources"
for pattern in \
    "binutils-*.tar.xz" \
    "gcc-*.tar.xz"       \
    "linux-*.tar.xz"     \
    "glibc-*.tar.xz"     \
    "mpfr-*.tar.*"      \
    "gmp-*.tar.*"       \
    "mpc-*.tar.*"; do

    match=$(ls "$SOURCES"/$pattern 2>/dev/null | head -1)
    if [ -n "$match" ]; then
        ok "$(basename "$match")"
    else
        fail "$pattern — not found in $SOURCES"
    fi
done

# ── Host compiler sanity ──────────────────────────────────────────────────────

echo ""
echo "--- Host compiler ---"

for tool in gcc g++ ld make bison gawk; do
    if type -p "$tool" > /dev/null 2>&1; then
        v=$($tool --version 2>&1 | head -1)
        ok "$tool: $v"
    else
        fail "$tool not found on host"
    fi
done

# ── Result ───────────────────────────────────────────────────────────────────

echo ""
echo "--- Results ---"
echo "  Passed: $PASS  |  Failed: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo "Fix the errors above before building the toolchain."
    exit 1
fi

echo "All checks passed. Ready to build."
