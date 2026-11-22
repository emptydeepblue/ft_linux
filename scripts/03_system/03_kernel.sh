#!/bin/bash
# System 03 — Linux kernel (LFS 12.4 §10.3)
#   sources  -> /usr/src/kernel-$KVER        (subject requirement)
#   image    -> /boot/vmlinuz-$KERNEL_RELEASE (e.g. vmlinuz-6.16.1-everonel)
#   config   -> make defconfig + config/kernel.config fragment
# Run INSIDE the chroot as root, with /boot mounted.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
FRAGMENT="$FT_ROOT/config/kernel.config"
SRC="/usr/src/kernel-$KVER"

echo ">>> Linux $KVER -> $KERNEL_RELEASE"

if ! mountpoint -q /boot; then
    echo "ERROR: /boot is not mounted (run lfs_disk.sh mount on the host)." >&2
    exit 1
fi

# ── Sources in /usr/src/kernel-$KVER ─────────────────────────────────────────
if [ ! -f "$SRC/Makefile" ]; then
    rm -rf "$SRC" "/usr/src/linux-$KVER"
    tar -xf "/sources/linux-$KVER.tar.xz" -C /usr/src
    mv "/usr/src/linux-$KVER" "$SRC"
fi
cd "$SRC"
make mrproper

# ── Configuration ────────────────────────────────────────────────────────────
make defconfig
scripts/kconfig/merge_config.sh -m .config "$FRAGMENT"
# Identity always from ft_linux.conf (the fragment holds the same defaults).
scripts/config --set-str LOCALVERSION "-$FT_LOGIN" \
               --disable LOCALVERSION_AUTO \
               --set-str DEFAULT_HOSTNAME "$FT_HOSTNAME"
make olddefconfig

# Every option of the fragment must have survived olddefconfig (an option
# with unmet dependencies is silently dropped otherwise).
missing=0
while IFS= read -r line; do
    case "$line" in
        CONFIG_*=*)
            sym="${line%%=*}"
            grep -qxF "$line" .config || {
                case "$sym" in CONFIG_LOCALVERSION|CONFIG_DEFAULT_HOSTNAME) continue ;; esac
                echo "  WARNING: $line -> $(grep -E "^(# )?$sym[= ]" .config || echo 'absent')"
                missing=$((missing + 1)); } ;;
        "# CONFIG_"*" is not set")
            sym="${line#\# }"; sym="${sym%% *}"
            if grep -q "^$sym=" .config; then
                echo "  WARNING: $sym should be disabled -> $(grep "^$sym=" .config)"
                missing=$((missing + 1))
            fi ;;
    esac
done < "$FRAGMENT"
[ "$missing" -eq 0 ] && echo "  All fragment options applied."

# kernelrelease reads CONFIG_LOCALVERSION from include/config/auto.conf,
# which only exists after syncconfig (otherwise it prints "6.16.1" only).
make -s syncconfig
RELEASE="$(make -s kernelrelease)"
if [ "$RELEASE" != "$KERNEL_RELEASE" ]; then
    echo "ERROR: kernelrelease is '$RELEASE', expected '$KERNEL_RELEASE'." >&2
    exit 1
fi
for sym in CONFIG_SATA_AHCI CONFIG_EXT4_FS CONFIG_E1000 CONFIG_DEVTMPFS; do
    grep -qx "$sym=y" .config || { echo "ERROR: $sym must be =y (built in)." >&2; exit 1; }
done

# ── Build and install ────────────────────────────────────────────────────────
make
make modules_install

cp -v arch/x86/boot/bzImage "/boot/vmlinuz-$KERNEL_RELEASE"
cp -v System.map            "/boot/System.map-$KERNEL_RELEASE"
cp -v .config               "/boot/config-$KERNEL_RELEASE"

install -d "/usr/share/doc/linux-$KVER"
cp -r Documentation -T "/usr/share/doc/linux-$KVER"

# The tree is kept (subject): make it owned by root, as the book advises.
chown -R 0:0 "$SRC"

echo "<<< Kernel done: /boot/vmlinuz-$KERNEL_RELEASE, sources in $SRC"
