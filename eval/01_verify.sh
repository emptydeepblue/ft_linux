#!/bin/bash
# 01_verify.sh — Compare the SHA-1 of the disk image with checksum.txt.
# Who/where: anyone, on the evaluation PC (no sudo). Run it BEFORE the first
# boot and again at the end: the disk is attached immutable, so it never changes.
#
# Usage: bash eval/01_verify.sh [path/to/ft_linux.vdi]     (default: ./ft_linux.vdi)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VDI="${1:-ft_linux.vdi}"
SUM_FILE="$HERE/../checksum.txt"

[ -f "$VDI" ]      || { echo "ERROR: $VDI not found (did you run: xz -dk ft_linux.vdi.xz ?)" >&2; exit 1; }
[ -f "$SUM_FILE" ] || { echo "ERROR: $SUM_FILE not found" >&2; exit 1; }

expected="$(awk 'NF {print $1; exit}' "$SUM_FILE")"
echo "Computing: shasum < $VDI   (a few seconds per GB)"
actual="$(shasum < "$VDI" | awk '{print $1}')"

echo "  checksum.txt : $expected"
echo "  $VDI : $actual"
if [ "$actual" = "$expected" ]; then
    echo "OK: the disk image is the one submitted."
else
    echo "MISMATCH: this is not the submitted disk image." >&2
    exit 1
fi
