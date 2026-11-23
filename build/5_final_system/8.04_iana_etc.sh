#!/bin/bash
# LFS 12.4 §8.4 — Iana-Etc
set -euo pipefail
echo ">>> Iana-Etc"
cd /sources
tar -xf iana-etc-*.tar.gz
cd iana-etc-*/
cp services protocols /etc/
cd /sources && rm -rf iana-etc-*/
echo "<<< Iana-Etc done"
