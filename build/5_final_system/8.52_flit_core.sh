#!/bin/bash
# LFS 12.4 §8.52 — Flit-core (Python build backend)
set -euo pipefail
echo ">>> Flit-core"
cd /sources
tar -xf flit_core-*.tar.gz
cd flit_core-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist flit_core
cd /sources && rm -rf flit_core-*/
echo "<<< Flit-core done"
