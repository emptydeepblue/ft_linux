#!/bin/bash
# Final system 41/79 — XML::Parser
set -euo pipefail
echo ">>> XML::Parser"
cd /sources
tar -xf XML-Parser-*.tar.gz
cd XML-Parser-*/
perl Makefile.PL
make
make install
cd /sources && rm -rf XML-Parser-*/
echo "<<< XML::Parser done"
