#!/bin/bash
# Final system 78/79 — Sysklogd
set -euo pipefail
echo ">>> Sysklogd"
cd /sources
tar -xf sysklogd-*.tar.gz
cd sysklogd-*/
./autogen.sh
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --runstatedir=/run
make
make install

cat > /etc/syslog.conf << "EOF"
# /etc/syslog.conf — LFS system logger configuration

auth,authpriv.*          -/var/log/auth.log
*.*;auth,authpriv.none   -/var/log/sys.log
daemon.*                 -/var/log/daemon.log
kern.*                   -/var/log/kern.log
mail.*                   -/var/log/user.log
user.*                   -/var/log/user.log
*.emerg                   *
EOF

cd /sources && rm -rf sysklogd-*/
echo "<<< Sysklogd done"
