#!/bin/bash
# LFS 12.4 §8.84 — Stripping: remove debugging symbols (hundreds of MB) from
# programs and libraries. A few libraries keep their symbols in a separate
# .dbg file (for debugging glibc/libstdc++ with gdb); libraries and programs
# that are in use while this runs are stripped on a copy, then installed.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> Stripping"
cd /usr/lib

# First match of an exact file name pattern in /usr/lib (versions not hardcoded)
pick() { find /usr/lib -maxdepth 1 -type f -regextype posix-extended -regex "/usr/lib/$1" -printf '%f\n'; }

save_usrlib="$(ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             $(pick 'libquadmath\.so\.0\.[0-9.]+')
             $(pick 'libstdc\+\+\.so\.6\.0\.[0-9]+')
             $(pick 'libitm\.so\.1\.[0-9.]+')
             $(pick 'libatomic\.so\.1\.[0-9.]+')"

for LIB in $save_usrlib; do
    objcopy --only-keep-debug --compress-debug-sections=zstd $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-debug /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

# In use right now (this shell, find, strip and their libraries): via a copy.
online_usrbin="bash find strip"
online_usrlib="$(pick 'libbfd-[0-9.]+\.so')
               $(pick 'libsframe\.so\.[0-9.]+')
               $(pick 'libhistory\.so\.8\.[0-9]+')
               $(pick 'libncursesw\.so\.6\.[0-9]+')
               libm.so.6
               $(pick 'libreadline\.so\.8\.[0-9]+')
               $(pick 'libz\.so\.1\.[0-9.]+')
               $(pick 'libzstd\.so\.1\.[0-9.]+')
               $(cd /usr/lib; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/$BIN /tmp/$BIN
    strip --strip-debug /tmp/$BIN
    install -vm755 /tmp/$BIN /usr/bin
    rm /tmp/$BIN
done

for LIB in $online_usrlib; do
    cp /usr/lib/$LIB /tmp/$LIB
    strip --strip-debug /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

# Everything else. Scripts and other non-ELF files make strip complain
# ("file format not recognized"): expected, as the book says.
for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-debug $i 2>/dev/null || true
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib
echo "<<< Stripping done"
