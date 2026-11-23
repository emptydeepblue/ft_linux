#!/bin/bash
# LFS 12.4 §8.44 — XML::Parser
set -euo pipefail
echo ">>> XML::Parser"
cd /sources
rm -rf XML-Parser-*/            # leftovers of an interrupted run
tar -xf XML-Parser-*.tar.gz
cd XML-Parser-*/
perl Makefile.PL
make
make install
cd /sources && rm -rf XML-Parser-*/
echo "<<< XML::Parser done"
