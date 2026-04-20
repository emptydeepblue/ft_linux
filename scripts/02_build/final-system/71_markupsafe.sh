#!/bin/bash
# Final system 71/79 — MarkupSafe (Python — required by Jinja2/Meson)
set -euo pipefail
echo ">>> MarkupSafe"
cd /sources
tar -xf MarkupSafe-*.tar.gz
cd MarkupSafe-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist markupsafe
cd /sources && rm -rf MarkupSafe-*/
echo "<<< MarkupSafe done"
