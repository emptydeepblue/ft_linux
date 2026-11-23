#!/bin/bash
# LFS 12.4 §8.5 — Glibc (final), with locales, time zone data, nsswitch and
# the dynamic loader configuration.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> Glibc"
cd /sources
rm -rf glibc-*/            # leftovers of an interrupted run
tar -xf glibc-*.tar.xz
cd glibc-*/

# FHS: runtime data in /var/lib, not /var/db
patch -Np1 -i ../glibc-*-fhs-1.patch
# Fix a lock in abort() (2.42 bug, from the book)
sed -e '/unistd.h/i #include <string.h>' \
    -e '/libc_rwlock_init/c\
  __libc_rwlock_define_initialized (, reset_lock);\
  memcpy (&lock, &reset_lock, sizeof (lock));' \
    -i stdlib/abort.c

mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.4
make
# (make check skipped: hours of tests; this build does not run test suites)

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
rm -f /usr/sbin/nscd

# Replace the libraries in use (the temporary Glibc) in a safe way first:
# overwriting a running libc in place can crash the programs using it.
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/*.so.* /usr/lib

# GCC pass 2 put its limits.h in include-fixed: move it where GCC looks.
DIR=$(dirname $(gcc -print-libgcc-file-name))
[ -e $DIR/include/limits.h ]    || mv $DIR/include{-fixed,}/limits.h
[ -e $DIR/include/syslimits.h ] || mv $DIR/include{-fixed,}/syslimits.h
rm -rfv $DIR/include-fixed/*
unset DIR

make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

# ── Locales: the book's minimal set (not all of them: smaller, faster) ──────
# localedef exits 1 even on mere warnings: do not stop on those, but check
# below that the locales the system uses really exist.
for l in \
    "C UTF-8 C.UTF-8" \
    "cs_CZ UTF-8 cs_CZ.UTF-8" \
    "de_DE ISO-8859-1 de_DE" \
    "de_DE@euro ISO-8859-15 de_DE@euro" \
    "de_DE UTF-8 de_DE.UTF-8" \
    "el_GR ISO-8859-7 el_GR" \
    "en_GB ISO-8859-1 en_GB" \
    "en_GB UTF-8 en_GB.UTF-8" \
    "en_HK ISO-8859-1 en_HK" \
    "en_PH ISO-8859-1 en_PH" \
    "en_US ISO-8859-1 en_US" \
    "en_US UTF-8 en_US.UTF-8" \
    "es_ES ISO-8859-15 es_ES@euro" \
    "es_MX ISO-8859-1 es_MX" \
    "fa_IR UTF-8 fa_IR" \
    "fr_FR ISO-8859-1 fr_FR" \
    "fr_FR@euro ISO-8859-15 fr_FR@euro" \
    "fr_FR UTF-8 fr_FR.UTF-8" \
    "is_IS ISO-8859-1 is_IS" \
    "is_IS UTF-8 is_IS.UTF-8" \
    "it_IT ISO-8859-1 it_IT" \
    "it_IT ISO-8859-15 it_IT@euro" \
    "it_IT UTF-8 it_IT.UTF-8" \
    "ja_JP EUC-JP ja_JP" \
    "ja_JP UTF-8 ja_JP.UTF-8" \
    "nl_NL@euro ISO-8859-15 nl_NL@euro" \
    "ru_RU KOI8-R ru_RU.KOI8-R" \
    "ru_RU UTF-8 ru_RU.UTF-8" \
    "se_NO UTF-8 se_NO.UTF-8" \
    "ta_IN UTF-8 ta_IN.UTF-8" \
    "tr_TR UTF-8 tr_TR.UTF-8" \
    "zh_CN GB18030 zh_CN.GB18030" \
    "zh_HK BIG5-HKSCS zh_HK.BIG5-HKSCS" \
    "zh_TW UTF-8 zh_TW.UTF-8"; do
    set -- $l
    localedef -i "$1" -f "$2" "$3" || echo "  (localedef warning for $3)"
done
for l in C.utf8 en_US.utf8 it_IT.utf8; do
    locale -a | grep -qx "$l" || { echo "ERROR: locale $l missing" >&2; exit 1; }
done

# ── Name service switch ──────────────────────────────────────────────────────
cat > /etc/nsswitch.conf << "EOF2"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF2

# ── Time zone data (subject: "Time Zone Data") ──────────────────────────────
tar -xf ../../tzdata*.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz
ln -sfv /usr/share/zoneinfo/UTC /etc/localtime

# ── Dynamic loader search path ───────────────────────────────────────────────
cat > /etc/ld.so.conf << "EOF2"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF2
mkdir -pv /etc/ld.so.conf.d

cd /sources && rm -rf glibc-*/
echo "<<< Glibc done"
