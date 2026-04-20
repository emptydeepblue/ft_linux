#!/bin/bash
# Final system 39/79 — Less
set -euo pipefail
echo ">>> Less"
cd /sources
tar -xf less-*.tar.gz
cd less-*/
./configure --prefix=/usr --sysconfdir=/etc
make
make install
cd /sources && rm -rf less-*/
echo "<<< Less done"
