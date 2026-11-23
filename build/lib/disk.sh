# disk.sh — helpers for the LFS target disk (source after common.sh).
#
# Two modes, chosen by LFS_DISK in config/ft_linux.conf:
#   LFS_DISK=""        image mode: $LFS_IMAGE attached to a loop device
#   LFS_DISK=/dev/sdX  block mode: a real (or virtual) disk
#
# Only the loop device bound to $LFS_IMAGE is ever touched: other loop
# devices (e.g. those of Docker Desktop, when it is running) are left alone;
# the number of ours varies (loop0 if Docker has none, loop2 otherwise).

# Partition N of a disk: /dev/sdb -> /dev/sdb1, /dev/loop3 -> /dev/loop3p1,
# /dev/nvme0n1 -> /dev/nvme0n1p1 (names ending in a digit get a "p").
ft_part() {
    case "$1" in
        *[0-9]) echo "${1}p$2" ;;
        *)      echo "${1}$2"  ;;
    esac
}

ft_image_mode() { [ -z "${LFS_DISK:-}" ]; }

# Loop device currently bound to $LFS_IMAGE (empty if none).
ft_loop_of_image() {
    losetup -j "$LFS_IMAGE" -n -O NAME 2>/dev/null | head -n1
}

# Attach $LFS_IMAGE (with partition scan) unless already attached; print it.
ft_loop_attach() {
    local dev
    dev="$(ft_loop_of_image)"
    if [ -z "$dev" ]; then
        dev="$(losetup -fP --show "$LFS_IMAGE")"
    fi
    echo "$dev"
}

# Print the target disk device (attaching the image if needed).
ft_target_dev() {
    if ft_image_mode; then
        [ -f "$LFS_IMAGE" ] || { echo "ERROR: image $LFS_IMAGE not found" >&2; return 1; }
        ft_loop_attach
    else
        echo "$LFS_DISK"
    fi
}

# Wait until the partition nodes of $1 exist (udev / devtmpfs may lag).
ft_wait_parts() {
    local dev="$1" n i
    for n in 1 2 3; do
        for i in $(seq 1 50); do
            [ -b "$(ft_part "$dev" "$n")" ] && break
            sleep 0.1
        done
        [ -b "$(ft_part "$dev" "$n")" ] || {
            echo "ERROR: $(ft_part "$dev" "$n") did not appear" >&2
            return 1
        }
    done
}
