#!/bin/bash
# LFS 12.4 §8.28 — Shadow
set -euo pipefail
echo ">>> Shadow"
cd /sources
tar -xf shadow-*.tar.xz
cd shadow-*/

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
# groups and some man pages are provided by Coreutils and Man-pages
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

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

# New users: group "users" (999), no mail spool
mkdir -p /etc/default
useradd -D --gid 999
sed -i '/MAIL/s/yes/no/' /etc/default/useradd

# The root password is set at the end of the build (6_boot/06_root_password.sh),
# so this phase runs unattended.

cd /sources && rm -rf shadow-*/
echo "<<< Shadow done"
