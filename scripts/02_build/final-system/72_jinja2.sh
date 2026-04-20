#!/bin/bash
# Final system 72/79 — Jinja2 (Python — required by Meson)
set -euo pipefail
echo ">>> Jinja2"
cd /sources
tar -xf Jinja2-*.tar.gz
cd Jinja2-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist jinja2
cd /sources && rm -rf Jinja2-*/
echo "<<< Jinja2 done"
