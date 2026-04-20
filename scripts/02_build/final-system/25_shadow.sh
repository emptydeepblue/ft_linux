#!/bin/bash
# Final system 25/79 — Shadow
set -euo pipefail
echo ">>> Shadow"
cd /sources
tar -xf shadow-*.tar.xz
cd shadow-*/

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name 'groups.1'  -delete
find man -name 'getspnam.3' -delete
find man -name 'passwd.5'  -delete

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                    \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                   \
    -i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man

# create standard groups
pwconv
grpconv

# set root password (interactive — type it when prompted)
echo ">>> Set the root password now:"
passwd root

cd /sources && rm -rf shadow-*/
echo "<<< Shadow done"
