#!/bin/bash
# LFS 12.4 §8.56 — Ninja
set -euo pipefail
echo ">>> Ninja"
cd /sources
rm -rf ninja-*/            # leftovers of an interrupted run
tar -xf ninja-*.tar.gz
cd ninja-*/
export NINJAJOBS=$(nproc)
# patch to respect NINJAJOBS env var
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion \
    /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion \
    /usr/share/zsh/site-functions/_ninja
unset NINJAJOBS
cd /sources && rm -rf ninja-*/
echo "<<< Ninja done"
