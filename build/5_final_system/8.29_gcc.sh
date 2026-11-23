#!/bin/bash
# LFS 12.4 §8.29 — GCC (final native build)
set -euo pipefail
echo ">>> GCC"
cd /sources
rm -rf gcc-*/            # leftovers of an interrupted run
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

# (make -k check skipped: hours of tests; this build does not run test suites)

chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/include{,-fixed}

# convenience symlinks
ln -svr /usr/bin/cpp /usr/lib                 # FHS: /usr/lib/cpp
ln -sfv gcc.1 /usr/share/man/man1/cc.1        # (cc -> gcc exists since ch. 6)

# LTO plugin for binutils
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/liblto_plugin.so \
        /usr/lib/bfd-plugins/

# sanity check
echo 'int main(){}' > /tmp/dummy.c
cc /tmp/dummy.c -o /tmp/a.out -v -Wl,--verbose &> /tmp/dummy.log
echo "--- Interpreter check ---"
readelf -l /tmp/a.out | grep ': /lib'
readelf -l /tmp/a.out | grep -q '/lib64/ld-linux-x86-64.so.2' \
    || { echo "FATAL: wrong ELF interpreter (see /tmp/dummy.log)" >&2; exit 1; }
echo "--- Should be /usr/lib/Scrt1.o / crti.o / crtn.o ---"
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' /tmp/dummy.log || true
rm -v /tmp/dummy.c /tmp/a.out /tmp/dummy.log

# Python helpers for gdb, where gdb looks for them
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /sources && rm -rf gcc-*/
echo "<<< GCC done"
