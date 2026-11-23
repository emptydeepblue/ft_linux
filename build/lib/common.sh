# common.sh — shared bootstrap for ft_linux scripts (source it, don't run it).
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
#
# Sets FT_ROOT (repo root, i.e. the directory holding build/ and config/)
# and loads config/ft_linux.conf, then config/ft_linux.local.conf if present.
# Works from the repo, from $LFS/sources/ft_linux (lfs user) and from
# /sources/ft_linux (chroot), because the layout below FT_ROOT is identical.

if [ -n "${FT_COMMON_LOADED:-}" ]; then
    return 0
fi
FT_COMMON_LOADED=1

FT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FT_CONF="${FT_CONF:-$FT_ROOT/config/ft_linux.conf}"

if [ ! -r "$FT_CONF" ]; then
    echo "ERROR: config not found: $FT_CONF" >&2
    exit 1
fi

# shellcheck source=../../config/ft_linux.conf
source "$FT_CONF"
if [ -r "$FT_ROOT/config/ft_linux.local.conf" ]; then
    # shellcheck disable=SC1091
    source "$FT_ROOT/config/ft_linux.local.conf"
fi

# Copy of the repo inside the LFS filesystem, as seen from the host.
FT_LFS_DIR="$LFS/$FT_LFS_SUBDIR"

export FT_ROOT FT_LOGIN FT_HOSTNAME LFS_VERSION KVER KERNEL_RELEASE \
       LFS JOBS FT_LFS_SUBDIR FT_LFS_DIR

# ── Who / where guards (each phase runs as a given user, in a given place) ───

ft_die() { echo "ERROR: $*" >&2; exit 1; }

ft_require_root() {
    [ "$(id -u)" -eq 0 ] || ft_die "run as root (sudo bash $0)"
}

ft_require_user() {
    [ "$(whoami)" = "$1" ] || ft_die "run as user '$1' (now: $(whoami))"
}

# True inside the LFS chroot: the scripts run from /sources/ft_linux, the copy
# made by sync_to_lfs.sh as seen from inside. (Comparing / with /proc/1/root
# does not work on WSL, where PID 1 already has a different root.)
ft_in_chroot() {
    [ "$FT_ROOT" = "/$FT_LFS_SUBDIR" ] && [ ! -d "$LFS/$FT_LFS_SUBDIR" ]
}

ft_require_chroot() {
    ft_require_root
    ft_in_chroot || ft_die "run INSIDE the chroot (sudo bash build/3_chroot/02_enter_chroot.sh)"
}

ft_require_host() {
    ! ft_in_chroot || ft_die "run on the HOST, not inside the chroot"
}
