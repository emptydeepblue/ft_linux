#!/bin/bash
# LFS 12.4 §8.73 — Vim
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
V=${PWD##*/vim-}                                   # 9.1.1629
ln -sv ../vim/vim$(echo "$V" | cut -d. -f1,2 | tr -d .)/doc /usr/share/doc/vim-$V   # vim91/doc

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd /sources && rm -rf vim-*/
echo "<<< Vim done"
