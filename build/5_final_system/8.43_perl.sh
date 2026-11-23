#!/bin/bash
# LFS 12.4 §8.43 — Perl (final native build)
set -euo pipefail
echo ">>> Perl"
cd /sources
tar -xf perl-*.tar.xz
cd perl-*/

PERL_VER=$(basename "$(pwd)" | sed 's/perl-//')
PERL_MINOR=$(echo "$PERL_VER" | sed 's/\.[0-9]*$//')

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                                        \
             -D prefix=/usr                                              \
             -D vendorprefix=/usr                                        \
             -D privlib=/usr/lib/perl5/${PERL_MINOR}/core_perl           \
             -D archlib=/usr/lib/perl5/${PERL_MINOR}/core_perl           \
             -D sitelib=/usr/lib/perl5/${PERL_MINOR}/site_perl           \
             -D sitearch=/usr/lib/perl5/${PERL_MINOR}/site_perl          \
             -D vendorlib=/usr/lib/perl5/${PERL_MINOR}/vendor_perl       \
             -D vendorarch=/usr/lib/perl5/${PERL_MINOR}/vendor_perl      \
             -D man1dir=/usr/share/man/man1                              \
             -D man3dir=/usr/share/man/man3                              \
             -D pager="/usr/bin/less -isR"                               \
             -D useshrplib                                               \
             -D usethreads

make
make install
unset BUILD_ZLIB BUILD_BZIP2
cd /sources && rm -rf perl-*/
echo "<<< Perl done"
