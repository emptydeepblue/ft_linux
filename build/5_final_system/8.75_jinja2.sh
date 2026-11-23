#!/bin/bash
# LFS 12.4 §8.75 — Jinja2 (Python — required by Meson)
set -euo pipefail
echo ">>> Jinja2"
cd /sources
rm -rf jinja2-*/            # leftovers of an interrupted run
tar -xf jinja2-*.tar.gz
cd jinja2-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist jinja2
cd /sources && rm -rf jinja2-*/
echo "<<< Jinja2 done"
