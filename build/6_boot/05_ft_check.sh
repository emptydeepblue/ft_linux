#!/bin/bash
# Boot step — install ft_check (eval/ft_check.sh) as /usr/local/bin/ft_check:
# during the defense it shows, live, every requirement of the subject.
# The login it checks for comes from config/ft_linux.conf.
# Run INSIDE the chroot as root.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
echo ">>> ft_check"
sed "s/^FT_LOGIN=\"\${FT_LOGIN:-[a-z0-9_-]*}\"/FT_LOGIN=\"\${FT_LOGIN:-$FT_LOGIN}\"/" \
    "$FT_ROOT/eval/ft_check.sh" > /usr/local/bin/ft_check
chmod 755 /usr/local/bin/ft_check
grep -q "FT_LOGIN:-$FT_LOGIN}" /usr/local/bin/ft_check \
    || { echo "ERROR: could not set the login in ft_check" >&2; exit 1; }
echo "<<< ft_check installed: /usr/local/bin/ft_check"
