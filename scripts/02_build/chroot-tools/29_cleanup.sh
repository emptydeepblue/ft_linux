#!/bin/bash
# Chroot tools step 29/29 — Strip and clean temporary tools
# Removes debug symbols, .la files, and cross-compiler headers
# to reclaim ~1 GB before building the final system.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Strip and clean temporary tools"

# ── Strip debug symbols ───────────────────────────────────────────────────────

# Skip libbfd and libopcodes — strip crashes on them and truncates the file,
# breaking the assembler (as) which links against libbfd.
find /usr/{lib,libexec} -name \*.so* -type f \
    ! -name 'libbfd*' ! -name 'libopcodes*' \
    -exec strip --strip-unneeded {} \; 2>/dev/null || true

find /usr/{bin,sbin} -type f \
    -exec strip --strip-all {} \; 2>/dev/null || true

# ── Remove static archives and libtool files ──────────────────────────────────

find /usr/{lib,libexec} -name \*.la -delete

# ── Remove cross-compiler include-fixed headers ───────────────────────────────

GCC_VER=$(ls /usr/lib/gcc)
GCC_TGT=$(ls /usr/lib/gcc/"$GCC_VER")
rm -rf /usr/lib/gcc/"$GCC_VER"/"$GCC_TGT"/include-fixed

# ── Remove documentation ──────────────────────────────────────────────────────

rm -rf /usr/share/{info,man,doc}/*

echo "<<< Strip and clean done"
echo ""
echo "Temporary tools are ready. Next: build the final system (Chapter 8)."
