#!/bin/bash
# ft_check — Show, live, that ft_linux meets every requirement of the subject.
# Who/where: root INSIDE ft_linux (installed as /usr/local/bin/ft_check).
# Read-only: it changes nothing. Exit status = number of failed checks.
#
# Usage: ft_check            (FT_LOGIN=<login> ft_check to check another login)

FT_LOGIN="${FT_LOGIN:-everonel}"
PASS=0; FAIL=0
ok()   { printf '  \033[32mOK\033[0m    %s\n' "$*"; PASS=$((PASS + 1)); }
ko()   { printf '  \033[31mFAIL\033[0m  %s\n' "$*"; FAIL=$((FAIL + 1)); }
check() { local msg="$1"; shift; if "$@" > /dev/null 2>&1; then ok "$msg"; else ko "$msg"; fi; }
title() { printf '\n\033[1m%s\033[0m\n' "$*"; }

REL="$(uname -r)"
KVER="${REL%%-*}"

title "Kernel"
check "version >= 4.0: $REL"                    test "${KVER%%.*}" -ge 4
check "release contains the login: $REL"        grep -q -- "$FT_LOGIN" <<< "$REL"
check "/boot/vmlinuz-$REL"                      test -f "/boot/vmlinuz-$REL"
check "sources in /usr/src/kernel-$KVER"        test -f "/usr/src/kernel-$KVER/Makefile"

title "Identity"
check "hostname = $FT_LOGIN ($(hostname))"      test "$(hostname)" = "$FT_LOGIN"

title "Partitions (root, /boot, swap)"
check "/      on $(findmnt -no SOURCE /)"       findmnt /
check "/boot  on $(findmnt -no SOURCE /boot)"   findmnt /boot
check "/boot is a separate partition"           test "$(findmnt -no SOURCE /)" != "$(findmnt -no SOURCE /boot)"
check "swap   on $(awk 'NR==2{print $1}' /proc/swaps)"  test "$(wc -l < /proc/swaps)" -ge 2

title "Boot chain"
check "bootloader: GRUB ($(grub-install --version 2>/dev/null))"  test -f /boot/grub/grub.cfg
check "grub.cfg boots vmlinuz-$REL"             grep -q "vmlinuz-$REL" /boot/grub/grub.cfg
check "init: SysVinit ($(readlink -f /sbin/init))"  test "$(cat /proc/1/comm)" = init
check "module loader: udevd running (eudev)"   pgrep -x udevd
check "kmod: $(kmod --version 2>/dev/null | head -1)"  command -v modprobe

title "Network"
check "default route: $(ip route show default 2>/dev/null | head -1)"  test -n "$(ip route show default)"
check "DNS resolves www.gnu.org"                getent hosts www.gnu.org
check "HTTPS download works (wget)"             wget -q --spider https://ftp.gnu.org/gnu/
check "sshd running (ssh -p 2222 root@localhost)" pgrep -x sshd

title "Packages of the subject (one binary or file each)"
missing=()
for item in \
    acl:getfacl attr:getfattr autoconf:autoconf automake:automake bash:bash bc:bc \
    binutils:ld bison:bison bzip2:bzip2 check:/usr/lib/libcheck.so coreutils:ls \
    dejagnu:runtest diffutils:diff eudev:udevadm e2fsprogs:mke2fs expat:/usr/lib/libexpat.so \
    expect:expect file:file findutils:find flex:flex gawk:gawk gcc:gcc gdbm:gdbmtool \
    gettext:gettext glibc:ldd gmp:/usr/lib/libgmp.so gperf:gperf grep:grep groff:groff \
    grub:grub-install gzip:gzip iana-etc:/etc/services inetutils:ping intltool:intltoolize \
    iproute2:ip kbd:loadkeys kmod:kmod less:less libcap:capsh libpipeline:/usr/lib/libpipeline.so \
    libtool:libtool m4:m4 make:make man-db:man man-pages:/usr/share/man/man2/open.2 \
    mpc:/usr/lib/libmpc.so mpfr:/usr/lib/libmpfr.so ncurses:tput patch:patch perl:perl \
    pkg-config:pkg-config procps:ps psmisc:killall readline:/usr/lib/libreadline.so sed:sed \
    shadow:passwd sysklogd:syslogd sysvinit:shutdown tar:tar tcl:tclsh texinfo:makeinfo \
    tzdata:/usr/share/zoneinfo/UTC udev-lfs:/etc/udev/rules.d/55-lfs.rules util-linux:mount \
    vim:vim xml-parser:/usr/lib/perl5 xz:xz zlib:/usr/lib/libz.so; do
    name="${item%%:*}"; what="${item#*:}"
    case "$what" in
        /*) [ -e "$what" ] ;;
        *)  command -v "$what" > /dev/null ;;
    esac || missing+=("$name($what)")
done
if [ "${#missing[@]}" -eq 0 ]; then ok "all present"; else ko "missing: ${missing[*]}"; fi

printf '\n%d OK, %d FAIL\n' "$PASS" "$FAIL"
exit "$FAIL"
