#!/bin/bash
# LFS 12.4 §8.3 — Man-pages
set -euo pipefail
echo ">>> Man-pages"
cd /sources
rm -rf man-pages-*/            # leftovers of an interrupted run
tar -xf man-pages-*.tar.xz
cd man-pages-*/
rm -v man3/crypt*                  # Libxcrypt provides better ones
make -R GIT=false prefix=/usr install
cd /sources && rm -rf man-pages-*/
echo "<<< Man-pages done"
