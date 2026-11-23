#!/bin/bash
# LFS 12.4 §7.9 — Perl
# Required by Autoconf, Automake, and other Ch.8 build systems.
# Run INSIDE the chroot as root.
set -euo pipefail

echo ">>> Perl"

cd /sources
tar -xf perl-*.tar.xz
cd perl-*/

# derive major.minor from directory name (e.g. perl-5.40.0 → 5.40)
PERL_VER=$(basename "$(pwd)" | sed 's/perl-//')
PERL_MINOR=$(echo "$PERL_VER" | sed 's/\.[0-9]*$//')

sh Configure -des                                                        \
             -D prefix=/usr                                              \
             -D vendorprefix=/usr                                        \
             -D useshrplib                                               \
             -D privlib=/usr/lib/perl5/${PERL_MINOR}/core_perl           \
             -D archlib=/usr/lib/perl5/${PERL_MINOR}/core_perl           \
             -D sitelib=/usr/lib/perl5/${PERL_MINOR}/site_perl           \
             -D sitearch=/usr/lib/perl5/${PERL_MINOR}/site_perl          \
             -D vendorlib=/usr/lib/perl5/${PERL_MINOR}/vendor_perl       \
             -D vendorarch=/usr/lib/perl5/${PERL_MINOR}/vendor_perl

make
make install

cd /sources
rm -rf perl-*/

echo "<<< Perl done"
