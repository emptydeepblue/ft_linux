#!/bin/bash
# Final system 69/79 — Texinfo
set -euo pipefail
echo ">>> Texinfo"
cd /sources
tar -xf texinfo-*.tar.xz
cd texinfo-*/
./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex
# rebuild info dir index
pushd /usr/share/info
    rm -vf dir
    for f in $(ls --ignore=dir); do
        install-info "$f" dir 2>/dev/null || true
    done
popd
cd /sources && rm -rf texinfo-*/
echo "<<< Texinfo done"
