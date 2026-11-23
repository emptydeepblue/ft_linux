#!/bin/bash
# Check — unit test framework for C. Not in the LFS 12.4 book (removed upstream):
# kept, right after Coreutils, because the subject lists it.
set -euo pipefail
echo ">>> Check"
cd /sources
rm -rf check-*/            # leftovers of an interrupted run
tar -xf check-*.tar.gz
cd check-*/
./configure --prefix=/usr --disable-static
make
make install
cd /sources && rm -rf check-*/
echo "<<< Check done"
