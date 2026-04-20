#!/bin/bash
# Final system 03/79 — Glibc
set -euo pipefail
echo ">>> Glibc"
cd /sources
tar -xf glibc-*.tar.xz
cd glibc-*/

# apply FHS patch if present
for p in ../glibc-*-fhs-*.patch; do
    [ -f "$p" ] && patch -Np1 -i "$p"
done

rm -rf build && mkdir -v build && cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                 \
             --disable-werror              \
             --enable-kernel=4.19          \
             --enable-stack-protector=strong \
             --disable-nscd               \
             libc_cv_slibdir=/usr/lib

make

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

# locale data
make localedata/install-locales
localedef -i C -f UTF-8 C.UTF-8

# timezone
cd /sources
mkdir -pv tzdata
cd tzdata
tar -xf ../tzdata*.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa \
          antarctica asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       $tz
    zic -L /dev/null   -d $ZONEINFO/posix $tz
    zic -L leapseconds -d $ZONEINFO/right $tz
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
ln -sfv /usr/share/zoneinfo/UTC /etc/localtime

# nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
passwd:    files
group:     files
shadow:    files
hosts:     files dns
networks:  files
protocols: files
services:  files
ethers:    files
rpc:       files
EOF

# ld.so.conf
cat > /etc/ld.so.conf << "EOF"
/usr/local/lib
/opt/lib
EOF

cd /sources && rm -rf glibc-*/ tzdata/
echo "<<< Glibc done"
