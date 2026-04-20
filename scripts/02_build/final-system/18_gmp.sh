#!/bin/bash
# Final system 18/79 — GMP
set -euo pipefail
echo ">>> GMP"

# GMP 6.3.0 + GCC 15 workaround: GMP's configure hardcodes -pedantic in its
# compiler probe tests.  GCC 15 rejects the C89-style void g(){} test program
# when -pedantic is active, causing configure to wrongly conclude that no
# working compiler exists.  Use wrapper scripts that strip -pedantic so the
# probe succeeds; the actual GMP build uses normal flags.
cat > /tmp/gmp_gcc << 'WRAP'
#!/bin/bash
args=()
has_std=0
for arg in "$@"; do
    [[ "$arg" == "-pedantic" ]] && continue
    [[ "$arg" == -std=* ]] && has_std=1
    args+=("$arg")
done
[[ $has_std -eq 0 ]] && args=("-std=gnu17" "${args[@]}")
exec /usr/bin/gcc "${args[@]}"
WRAP
cat > /tmp/gmp_gxx << 'WRAP'
#!/bin/bash
args=()
has_std=0
for arg in "$@"; do
    [[ "$arg" == "-pedantic" ]] && continue
    [[ "$arg" == -std=* ]] && has_std=1
    args+=("$arg")
done
[[ $has_std -eq 0 ]] && args=("-std=gnu++17" "${args[@]}")
exec /usr/bin/g++ "${args[@]}"
WRAP
chmod +x /tmp/gmp_gcc /tmp/gmp_gxx

cd /sources
tar -xf gmp-*.tar.xz
cd gmp-*/
GMP_VER=$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'")
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-${GMP_VER} \
            CC=/tmp/gmp_gcc CXX=/tmp/gmp_gxx
make
make html
make install
make install-html
rm -f /tmp/gmp_gcc /tmp/gmp_gxx
cd /sources && rm -rf gmp-*/
echo "<<< GMP done"
