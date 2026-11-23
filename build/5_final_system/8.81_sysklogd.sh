#!/bin/bash
# LFS 12.4 §8.81 — Sysklogd (system logger: kernel and daemon messages to /var/log)
set -euo pipefail
echo ">>> Sysklogd"
cd /sources
rm -rf sysklogd-*/            # leftovers of an interrupted run
tar -xf sysklogd-*.tar.gz
cd sysklogd-*/
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --runstatedir=/run \
            --without-logger   \
            --disable-static   \
            --docdir=/usr/share/doc/${PWD##*/}
make
make install

cat > /etc/syslog.conf << "EOF2"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# Do not open any internet ports.
secure_mode 2

# End /etc/syslog.conf
EOF2

cd /sources && rm -rf sysklogd-*/
echo "<<< Sysklogd done"
