#!/bin/bash
# System 07 — make-ca (BLFS 12.4) — builds the CA certificate stores
# (/etc/pki/anchors, /etc/ssl/certs, /etc/pki/tls/certs/ca-bundle.crt) so that
# wget/openssl can verify HTTPS servers during the evaluation.
# make-ca -g DOWNLOADS Mozilla's certdata.txt: needs network in the chroot.
# Run INSIDE the chroot as root.
set -euo pipefail
echo ">>> make-ca"
cd /sources
tar -xf make-ca-*.tar.gz
cd make-ca-*/
make install
install -vdm755 /etc/ssl/local
cd /sources && rm -rf make-ca-*/

if ! /usr/sbin/make-ca -g; then
    echo "ERROR: make-ca -g failed (no network in the chroot?)." >&2
    echo "  Check: getent hosts hg.mozilla.org ; cat /etc/resolv.conf" >&2
    echo "  Then rerun: bash \$FT_DIR/scripts/03_system/07_make_ca.sh" >&2
    exit 1
fi

# Let pip (Python) use the same bundle.
mkdir -pv /etc/profile.d
cat > /etc/profile.d/pythoncerts.sh << "EOF"
# Begin /etc/profile.d/pythoncerts.sh

export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt

# End /etc/profile.d/pythoncerts.sh
EOF

echo "  CA certificates: $(ls /etc/ssl/certs/*.pem 2>/dev/null | wc -l) in /etc/ssl/certs"
echo "<<< make-ca done"
