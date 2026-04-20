#!/bin/bash
# Final system 26/79 — GCC (final native build)
set -euo pipefail
echo ">>> GCC"
cd /sources
tar -xf gcc-*.tar.xz
cd gcc-*/

case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
esac

mkdir -v build && cd build

../configure --prefix=/usr            \
             LD=ld                     \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

make
make install

chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/{include{,-fixed},}

# convenience symlinks
ln -svr /usr/bin/cpp /usr/lib
ln -sfv gcc /usr/bin/cc

# LTO plugin for binutils
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/liblto_plugin.so \
        /usr/lib/bfd-plugins/

# sanity check
echo 'int main(){}' > /tmp/dummy.c
cc /tmp/dummy.c -o /tmp/a.out -v -Wl,--verbose &> /tmp/dummy.log
echo "--- Interpreter check ---"
readelf -l /tmp/a.out | grep ': /lib'
echo "--- Should be /usr/lib/Scrt1.o / crti.o / crtn.o ---"
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' /tmp/dummy.log || true
rm -v /tmp/dummy.c /tmp/a.out /tmp/dummy.log

cd /sources && rm -rf gcc-*/
echo "<<< GCC done"
