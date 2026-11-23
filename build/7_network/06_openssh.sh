#!/bin/bash
# Network step — OpenSSH (BLFS 12.4) + its SysV service script.
# Lets the evaluation be driven from the PC's own terminal (copy-paste,
# scrollback): eval/02_create_vm.sh forwards 127.0.0.1:2222 -> VM:22.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> OpenSSH"

# Privilege-separation user and directory (idempotent).
install -v -g sys -m700 -d /var/lib/sshd
getent group sshd > /dev/null || groupadd -g 50 sshd
id sshd > /dev/null 2>&1 || \
    useradd -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g sshd           \
            -s /bin/false     \
            -u 50 sshd

cd /sources
rm -rf openssh-*/            # leftovers of an interrupted run
tar -xf openssh-*.tar.gz
cd openssh-*/
./configure --prefix=/usr                            \
            --sysconfdir=/etc/ssh                    \
            --with-privsep-path=/var/lib/sshd        \
            --with-default-path=/usr/bin             \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run
make
make install
install -v -m755 contrib/ssh-copy-id   /usr/bin
install -v -m644 contrib/ssh-copy-id.1 /usr/share/man/man1
cd /sources && rm -rf openssh-*/

# Root may log in with a password: the VM is only reachable from the PC that
# runs it (NAT, port forward bound to 127.0.0.1). Deviation from BLFS, which
# suggests "PermitRootLogin no" for a real server.
grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config \
    || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Host keys: the disk image is public, so no private key is shipped in it.
# make install generated some: delete them; the boot script creates new ones.
rm -fv /etc/ssh/ssh_host_*

# SysV service (start in runlevels 2-5) from blfs-bootscripts.
tar -xf blfs-bootscripts-*.tar.xz
cd blfs-bootscripts-*/
make install-sshd
cd /sources && rm -rf blfs-bootscripts-*/
# Generate the missing host keys before sshd starts.
sed -i '/log_info_msg "Starting SSH Server..."/a\        /usr/bin/ssh-keygen -A > /dev/null' \
    /etc/rc.d/init.d/sshd
grep -q 'ssh-keygen -A' /etc/rc.d/init.d/sshd \
    || { echo "ERROR: could not add ssh-keygen -A to /etc/rc.d/init.d/sshd" >&2; exit 1; }

echo "<<< OpenSSH done (ssh -p 2222 root@localhost from the host)"
