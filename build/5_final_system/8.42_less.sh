#!/bin/bash
# LFS 12.4 §8.42 — Less
set -euo pipefail
echo ">>> Less"
cd /sources
rm -rf less-*/            # leftovers of an interrupted run
tar -xf less-*.tar.gz
cd less-*/
./configure --prefix=/usr --sysconfdir=/etc
make
make install
cd /sources && rm -rf less-*/
echo "<<< Less done"
