#!/bin/bash
# LFS 12.4 §8.55 — Setuptools (Python packaging)
set -euo pipefail
echo ">>> Setuptools"
cd /sources
tar -xf setuptools-*.tar.gz
cd setuptools-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools
cd /sources && rm -rf setuptools-*/
echo "<<< Setuptools done"
