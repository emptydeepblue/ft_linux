#!/bin/bash
# LFS 12.4 §8.54 — Wheel (Python build tool)
set -euo pipefail
echo ">>> Wheel"
cd /sources
tar -xf wheel-*.tar.gz
cd wheel-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist wheel
cd /sources && rm -rf wheel-*/
echo "<<< Wheel done"
