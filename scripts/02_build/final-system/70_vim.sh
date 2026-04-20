#!/bin/bash
# Final system 70/79 — Vim
set -euo pipefail
echo ">>> Vim"
cd /sources
tar -xf vim-*.tar.gz
cd vim-*/
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
make install
ln -sv vim /usr/bin/vi
for m in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 "$(dirname $m)/vi.1"
done
VER=$(echo vim-*/ | head -1 | sed 's/vim-\(.*\)\//\1/' | tr -d '/')
ln -sv ../vim/vim${VER//./}/doc /usr/share/doc/vim-${VER} 2>/dev/null || true

cat > /etc/vimrc << "EOF"
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif
EOF

cd /sources && rm -rf vim-*/
echo "<<< Vim done"
