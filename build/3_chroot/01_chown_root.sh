#!/bin/bash
# 01_chown_root.sh — LFS 12.4 §7.2: give the LFS tree back to root.
# Who/where: root on the HOST, once, after 2_toolchain and before the chroot.
#
# During ch. 5–6 the files were created by the lfs user, whose UID does not
# exist inside ft_linux. `--from lfs` only touches files still owned by lfs,
# so running this twice is harmless.
#
# Usage: sudo bash build/3_chroot/01_chown_root.sh
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ft_require_root
ft_require_host
mountpoint -q "$LFS" || ft_die "$LFS is not mounted (sudo bash build/lfs_disk.sh mount)"

echo "=== §7.2 Changing ownership to root ==="
# Book: usr var etc tools lib64. Plus sources: build dirs and logs left there by lfs.
for d in usr lib64 var etc tools sources; do
    [ -e "$LFS/$d" ] || continue
    chown --from lfs -R root:root "$LFS/$d"
    echo "  $LFS/$d"
done

left="$(find "$LFS" -xdev -user lfs -print -quit 2>/dev/null || true)"
[ -z "$left" ] || ft_die "still owned by lfs: $left"
echo "Done: nothing under $LFS is owned by lfs."
echo ""
echo "Next: sudo bash build/3_chroot/02_enter_chroot.sh"
