#!/bin/bash
# 02_env_setup.sh — Create lfs user, directory layout, and shell environment
# Run as root on the HOST system.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# ── Guards ───────────────────────────────────────────────────────────────────

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run as root (sudo bash $0)" >&2
    exit 1
fi

if ! mountpoint -q "$LFS"; then
    echo "ERROR: $LFS is not mounted. Run 01_disk_partition.sh first." >&2
    exit 1
fi

if ! mountpoint -q "$LFS/boot"; then
    echo "ERROR: $LFS/boot is not mounted. Run 01_disk_partition.sh first." >&2
    exit 1
fi

echo "=== LFS Environment Setup ==="
echo "  LFS: $LFS"
echo ""

# ── Directory layout ─────────────────────────────────────────────────────────

echo "[1/5] Creating LFS directory layout..."

mkdir -pv "$LFS/sources"
chmod -v  a+wt "$LFS/sources"       # sticky + world-writable (like /tmp)
mkdir -pv "$LFS/tools"
mkdir -pv "$LFS/etc" "$LFS/var"
mkdir -pv "$LFS/usr/bin" "$LFS/usr/lib" "$LFS/usr/sbin"

# Unified /bin, /lib, /sbin pointing into /usr (FHS merged layout)
for i in bin lib sbin; do
    ln -sfv "usr/$i" "$LFS/$i" 2>/dev/null || true
done

# On x86_64, create /lib64 for the ELF interpreter
case $(uname -m) in
    x86_64) mkdir -pv "$LFS/lib64" ;;
esac

echo "      Done."

# ── lfs user ─────────────────────────────────────────────────────────────────

echo "[2/5] Creating lfs user..."

if ! getent group lfs > /dev/null 2>&1; then
    groupadd lfs
    echo "      Group lfs created."
else
    echo "      Group lfs already exists."
fi

if ! id lfs > /dev/null 2>&1; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "      User lfs created. Set a password:"
    passwd lfs
else
    echo "      User lfs already exists."
fi

# ── Ownership ────────────────────────────────────────────────────────────────

echo "[3/5] Setting lfs ownership on LFS directories..."

chown -v lfs "$LFS/tools" "$LFS/sources"
chown -v lfs "$LFS/usr" "$LFS/usr/bin" "$LFS/usr/lib" "$LFS/usr/sbin"
chown -v lfs "$LFS/lib" "$LFS/var" "$LFS/etc" "$LFS/bin" "$LFS/sbin" "$LFS/boot"

case $(uname -m) in
    x86_64) chown -v lfs "$LFS/lib64" ;;
esac

echo "      Done."

# ── Shell environment ─────────────────────────────────────────────────────────

echo "[4/5] Writing lfs shell environment..."

# .bash_profile — starts a clean shell (no inherited host env vars)
cat > /home/lfs/.bash_profile << 'EOF'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# .bashrc — sets all variables needed for cross-compilation.
# LFS, MAKEFLAGS and FT_DIR are expanded now, from config/ft_linux.conf.
cat > /home/lfs/.bashrc << EOF
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=\$LFS/tools/bin:/usr/bin:/bin
CONFIG_SITE=\$LFS/usr/share/config.site
MAKEFLAGS=-j$JOBS
FT_DIR=$FT_LFS_DIR
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS FT_DIR
EOF

chown lfs:lfs /home/lfs/.bash_profile /home/lfs/.bashrc
echo "      Done."

# ── Repo copy readable by lfs and by the chroot ──────────────────────────────

echo "[5/5] Copying scripts and config into $FT_LFS_DIR..."
bash "$FT_ROOT/scripts/sync_to_lfs.sh"

# ── Verify ───────────────────────────────────────────────────────────────────

echo ""
echo "=== Verify ==="
echo ""
echo "Directory layout:"
ls -la "$LFS/"
echo ""
echo "Ownership (should all be lfs):"
stat -c "%U:%G %n" "$LFS/tools" "$LFS/sources" "$LFS/usr"
echo ""
echo "Environment files:"
cat /home/lfs/.bashrc
echo ""
echo "Done. Switch to lfs user:"
echo "  sudo su - lfs"
echo "Then verify:"
echo "  echo \$LFS \$LFS_TGT"
echo "  echo \$PATH"
echo ""
echo "Next: sudo su - lfs && bash \$FT_DIR/scripts/01_setup/03_download_sources.sh"
