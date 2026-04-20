#!/bin/bash
# Final system 61/79 — GRUB
# Installs GRUB tools only. Actual bootloader install happens in Ch.10.
set -euo pipefail
echo ">>> GRUB"
cd /sources
tar -xf grub-*.tar.xz
cd grub-*/

# clear flags — GRUB must build with its own settings
unset {C,CPP,CXX,LD}FLAGS

echo depends bli part_gpt >> grub-core/extra_deps.lst

./configure --prefix=/usr          \
            --sysconfdir=/etc       \
            --disable-efiemu        \
            --disable-werror
make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions/grub \
    2>/dev/null || true
cd /sources && rm -rf grub-*/
echo "<<< GRUB done"
echo "NOTE: GRUB will be installed to the MBR/EFI in Chapter 10."
