#!/bin/bash
# System 08 — Wget (BLFS 12.4), HTTPS through OpenSSL + make-ca's certificates.
# Used during the evaluation to download sources. libpsl (recommended, not
# required) is not built: it only affects cookie domain checks.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> Wget"
cd /sources
tar -xf wget-*.tar.gz
cd wget-*/
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl \
            --without-libpsl
make
make install
cd /sources && rm -rf wget-*/

# Smoke test (non fatal: the chroot may have no network).
if wget -q --spider --timeout=10 https://www.linuxfromscratch.org/; then
    echo "  HTTPS test OK (certificate verified)."
else
    echo "  WARNING: HTTPS test failed — check network/certificates after boot."
fi
echo "<<< Wget done"
