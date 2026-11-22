#!/bin/bash
# Chroot tools step 23/29 — Gettext (temporary installation)
# Only msgfmt, msgmerge, and xgettext are needed at this stage.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Gettext (temporary)"

cd /sources
tar -xf gettext-*.tar.xz
cd gettext-*/

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf gettext-*/

echo "<<< Gettext done"
