#!/bin/bash
# Final system — Packaging (LFS 12.4 §8.53, Python module needed by Wheel/Meson)
set -euo pipefail
echo ">>> Packaging"
cd /sources
tar -xf packaging-*.tar.gz
cd packaging-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist packaging
cd /sources && rm -rf packaging-*/
echo "<<< Packaging done"
