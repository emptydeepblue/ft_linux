#!/bin/bash
# LFS 12.4 §8.72 — Texinfo
set -euo pipefail
echo ">>> Texinfo"
cd /sources
tar -xf texinfo-*.tar.xz
cd texinfo-*/
# Fix a wrong test that breaks some outputs (book)
sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm
./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex
# rebuild info dir index
pushd /usr/share/info
    rm -vf dir
    for f in $(ls --ignore=dir); do
        install-info "$f" dir 2>/dev/null || true   # not every file is an info page
    done
popd
cd /sources && rm -rf texinfo-*/
echo "<<< Texinfo done"
