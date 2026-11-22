# common.sh — shared bootstrap for ft_linux scripts (source it, don't run it).
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
#
# Sets FT_ROOT (repo root, i.e. the directory holding scripts/ and config/)
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
