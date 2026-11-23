#!/bin/bash
# LFS 12.4 §8.74 — MarkupSafe (Python — required by Jinja2/Meson)
set -euo pipefail
echo ">>> MarkupSafe"
cd /sources
tar -xf markupsafe-*.tar.gz
cd markupsafe-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist markupsafe
cd /sources && rm -rf markupsafe-*/
echo "<<< MarkupSafe done"
