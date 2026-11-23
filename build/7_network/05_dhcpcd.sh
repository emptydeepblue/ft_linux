#!/bin/bash
# Network step — dhcpcd (BLFS 12.4) + its SysV service script (blfs-bootscripts).
# With /etc/sysconfig/ifconfig.eth0 (SERVICE=dhcpcd, written by
# 02_system_config.sh) the network comes up at boot via DHCP (VirtualBox NAT).
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> dhcpcd"

# Privilege-separation user (idempotent).
install -v -m700 -d /var/lib/dhcpcd
getent group dhcpcd > /dev/null || groupadd -g 52 dhcpcd
id dhcpcd > /dev/null 2>&1 || \
    useradd -c 'dhcpcd PrivSep' \
            -d /var/lib/dhcpcd  \
            -g dhcpcd           \
            -s /bin/false       \
            -u 52 dhcpcd
chown -v dhcpcd:dhcpcd /var/lib/dhcpcd

cd /sources
rm -rf dhcpcd-*/            # leftovers of an interrupted run
tar -xf dhcpcd-*.tar.xz
cd dhcpcd-*/
./configure --prefix=/usr                \
            --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --privsepuser=dhcpcd
make
make install
cd /sources && rm -rf dhcpcd-*/

# /lib/services/dhcpcd, used by the ifup of lfs-bootscripts.
tar -xf blfs-bootscripts-*.tar.xz
cd blfs-bootscripts-*/
make install-service-dhcpcd
cd /sources && rm -rf blfs-bootscripts-*/

echo "<<< dhcpcd done"
