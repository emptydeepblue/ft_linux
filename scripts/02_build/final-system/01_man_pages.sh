#!/bin/bash
# Final system 01/79 — Man-pages
set -euo pipefail
echo ">>> Man-pages"
cd /sources
tar -xf man-pages-*.tar.xz
cd man-pages-*/
rm -v man3/crypt{,_r}.3
make -R prefix=/usr install
cd /sources && rm -rf man-pages-*/
echo "<<< Man-pages done"
