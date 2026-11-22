# Final System — Chapter 8 — ft_linux

72 packages built **natively inside the chroot** in strict dependency order.
Every package installs directly to `/usr` — no DESTDIR, no cross flags.

**All commands run inside the chroot as root** (entered via `03_enter_chroot.sh`).

> **Order = LFS 12.4 SysV chapter 8.** The authoritative list is `STEPS` in
> `scripts/02_build/05_run_final_system.sh` (script file numbers are historical).
> Glibc needs Python at build time: it comes from Chapter 7
> (`chroot-tools/26_python.sh`), so no bootstrap is needed here.
> Deviations from the book: Eudev instead of Udev-from-Systemd, Check kept
> (both required by the subject). Tables below may use the old numbering.

---

## Quick run (automated)

```bash
# inside the chroot
bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh

# resume from step N after a failure
bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh <N>
```

> **Shadow** is **interactive** — it prompts for the root password.
> **GCC** is the longest build — expect 30–90 min.
> If automating, build up to Shadow, set the password, then resume the runner
> from the GCC step. Pass the step numbers printed by `05_run_final_system.sh`
> to its resume argument (in that runner: Shadow = 26, GCC = 27).

---

## Manual run (step by step)

Enter the chroot first if not already inside:
```bash
sudo bash scripts/02_build/03_enter_chroot.sh
```

---

### Step 1 — Man-pages

Installs manual pages for Linux interfaces. No build — just install.

```bash
cd /sources && tar -xf man-pages-*.tar.xz && cd man-pages-*/
rm -v man3/crypt{,_r}.3
make -R prefix=/usr install
cd /sources && rm -rf man-pages-*/
```

---

### Step 2 — Iana-Etc

Provides `/etc/services` and `/etc/protocols` from the IANA registry.

```bash
cd /sources && tar -xf iana-etc-*.tar.gz && cd iana-etc-*/
cp services protocols /etc/
cd /sources && rm -rf iana-etc-*/
```

---

### Step 3 — Glibc

The core C library. Most complex package in this chapter.

```bash
cd /sources && tar -xf glibc-*.tar.xz && cd glibc-*/

for p in ../glibc-*-fhs-*.patch; do [ -f "$p" ] && patch -Np1 -i "$p"; done

rm -rf build && mkdir -v build && cd build
echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                   \
             --disable-werror                \
             --enable-kernel=4.19            \
             --enable-stack-protector=strong \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib
make
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
make localedata/install-locales
localedef -i C -f UTF-8 C.UTF-8
```

**Timezone data** (run once, pick your timezone):
```bash
cd /sources && mkdir tzdata && cd tzdata && tar -xf ../tzdata*.tar.gz
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
# set your timezone — list available: ls /usr/share/zoneinfo
ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

**Configuration files:**
```bash
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

cat > /etc/ld.so.conf << "EOF"
/usr/local/lib
/opt/lib
EOF

cd /sources && rm -rf glibc-*/ tzdata/
```

---

### Step 4 — Zlib

Compression library needed by many packages.

```bash
cd /sources && tar -xf zlib-*.tar.gz && cd zlib-*/
./configure --prefix=/usr
make && make install
rm -fv /usr/lib/libz.a
cd /sources && rm -rf zlib-*/
```

---

### Step 5 — Bzip2

The shared library must be built separately before the main install.

```bash
cd /sources && tar -xf bzip2-*.tar.gz && cd bzip2-*/
for p in ../bzip2-*-install_docs-*.patch; do [ -f "$p" ] && patch -Np1 -i "$p"; done
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s|man/man1|share/man/man1|g" Makefile
make -f Makefile-libbz2_so
make clean && make
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2
for b in /usr/bin/{bzcat,bunzip2}; do ln -sfv bzip2 $b; done
rm -fv /usr/lib/libbz2.a
cd /sources && rm -rf bzip2-*/
```

---

### Step 6 — Xz

```bash
cd /sources && tar -xf xz-*.tar.xz && cd xz-*/
./configure --prefix=/usr --disable-static \
            --docdir=/usr/share/doc/xz-$(cat doc/version)
make && make install
cd /sources && rm -rf xz-*/
```

---

### Step 7 — File

```bash
cd /sources && tar -xf file-*.tar.gz && cd file-*/
./configure --prefix=/usr
make && make install
cd /sources && rm -rf file-*/
```

---

### Step 8 — Readline

Link with `-lncursesw` explicitly to pick up wide-character support.

```bash
cd /sources && tar -xf readline-*.tar.gz && cd readline-*/
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
./configure --prefix=/usr --disable-static --with-curses \
            --docdir=/usr/share/doc/readline-$(cat version)
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
cd /sources && rm -rf readline-*/
```

---

### Step 9 — M4

```bash
cd /sources && tar -xf m4-*.tar.xz && cd m4-*/
./configure --prefix=/usr
make && make install
cd /sources && rm -rf m4-*/
```

---

### Step 10 — Bc

```bash
cd /sources && tar -xf bc-*.tar.xz && cd bc-*/
CC=gcc ./configure --prefix=/usr -G -O3 -r
make && make install
cd /sources && rm -rf bc-*/
```

---

### Step 11 — Flex

```bash
cd /sources && tar -xf flex-*.tar.gz && cd flex-*/
./configure --prefix=/usr --disable-static \
            --docdir=/usr/share/doc/flex-$(cat version)
make && make install
ln -sv flex /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1
cd /sources && rm -rf flex-*/
```

---

### Step 12 — Tcl

The configure scripts embed the source path — `sed` fixes are required after install.

```bash
cd /sources && tar -xf tcl*-src.tar.gz && SRCDIR=$(pwd)/tcl8.*/ && cd tcl8.*/
cd unix
./configure --prefix=/usr --mandir=/usr/share/man
make && make install
chmod -v u+w /usr/lib/libtcl*.so
make install-private-headers
ln -sfv tclsh$(ls /usr/bin/tclsh* | grep -o '[0-9]\+\.[0-9]\+') /usr/bin/tclsh
sed -e "s|$SRCDIR/unix|/usr/lib|" -e "s|$SRCDIR|/usr/include|" -i /usr/lib/tclConfig.sh
cd /sources && rm -rf tcl*/
```

---

### Step 13 — Expect

> **GCC 15 patch required.** Expect 5.45.4 uses implicit function declarations that are errors under GCC 15. Apply the patch before configuring.

```bash
cd /sources && tar -xf expect*.tar.gz && cd expect*/
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared \
            --mandir=/usr/share/man --with-tclinclude=/usr/include
make && make install
cd /sources && rm -rf expect*/
```

---

### Step 14 — DejaGNU

```bash
cd /sources && tar -xf dejagnu-*.tar.gz && cd dejagnu-*/
mkdir build && cd build
../configure --prefix=/usr
makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
make install
cd /sources && rm -rf dejagnu-*/
```

---

### Step 15 — Pkgconf (pkg-config)

```bash
cd /sources && tar -xf pkgconf-*.tar.xz && cd pkgconf-*/
./configure --prefix=/usr --disable-static
make && make install
ln -sv pkgconf /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
cd /sources && rm -rf pkgconf-*/
```

---

### Step 16 — Binutils (final)

```bash
cd /sources && tar -xf binutils-*.tar.xz && cd binutils-*/
mkdir -v build && cd build
../configure --prefix=/usr --sysconfdir=/etc     \
             --enable-gold --enable-ld=default    \
             --enable-plugins --enable-shared     \
             --disable-werror --enable-64-bit-bfd \
             --enable-new-dtags --with-system-zlib \
             --enable-default-hash-style=gnu
make tooldir=/usr
make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
cd /sources && rm -rf binutils-*/
```

---

### Step 17 — GMP

```bash
cd /sources && tar -xf gmp-*.tar.xz && cd gmp-*/
./configure --prefix=/usr --enable-cxx --disable-static
make && make html && make install && make install-html
cd /sources && rm -rf gmp-*/
```

---

### Step 18 — MPFR

```bash
cd /sources && tar -xf mpfr-*.tar.xz && cd mpfr-*/
./configure --prefix=/usr --disable-static --enable-thread-safe
make && make html && make install && make install-html
cd /sources && rm -rf mpfr-*/
```

---

### Step 19 — MPC

```bash
cd /sources && tar -xf mpc-*.tar.gz && cd mpc-*/
./configure --prefix=/usr --disable-static
make && make html && make install && make install-html
cd /sources && rm -rf mpc-*/
```

---

### Step 20 — Attr

```bash
cd /sources && tar -xf attr-*.tar.gz && cd attr-*/
./configure --prefix=/usr --disable-static --sysconfdir=/etc
make && make install
cd /sources && rm -rf attr-*/
```

---

### Step 21 — Acl

```bash
cd /sources && tar -xf acl-*.tar.xz && cd acl-*/
./configure --prefix=/usr --disable-static
make && make install
cd /sources && rm -rf acl-*/
```

---

### Step 22 — Libcap

```bash
cd /sources && tar -xf libcap-*.tar.xz && cd libcap-*/
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make prefix=/usr lib=lib install
cd /sources && rm -rf libcap-*/
```

---

### Step 23 — Libxcrypt

```bash
cd /sources && tar -xf libxcrypt-*.tar.xz && cd libxcrypt-*/
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
make && make install
cd /sources && rm -rf libxcrypt-*/
```

---

### Step 24 — Shadow ⚠️ Interactive

Sets up user/password management. Prompts for the **root password** at the end.

```bash
cd /sources && tar -xf shadow-*.tar.xz && cd shadow-*/
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name 'groups.1' -delete
find man -name 'getspnam.3' -delete
find man -name 'passwd.5' -delete
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                    \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                   \
    -i etc/login.defs
touch /usr/bin/passwd
./configure --sysconfdir=/etc --disable-static \
            --with-{b,yes}crypt --without-libbsd \
            --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man
pwconv && grpconv
passwd root          # ← type your root password here (lfsdevQ1)
cd /sources && rm -rf shadow-*/
```

---

### Step 25 — GCC (final)

Largest package — expect 30–90 min depending on `-j`.

```bash
cd /sources && tar -xf gcc-*.tar.xz && cd gcc-*/
case $(uname -m) in
    x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;
esac
rm -rf build && mkdir -v build && cd build
../configure --prefix=/usr LD=ld           \
             --enable-languages=c,c++       \
             --enable-default-pie           \
             --enable-default-ssp           \
             --enable-host-pie              \
             --disable-multilib             \
             --disable-bootstrap            \
             --disable-fixincludes          \
             --with-system-zlib
make && make install
chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/{include{,-fixed},}
ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$(gcc -dumpversion)/liblto_plugin.so \
        /usr/lib/bfd-plugins/
# sanity check
echo 'int main(){}' > /tmp/dummy.c && cc /tmp/dummy.c -o /tmp/a.out -v -Wl,--verbose &> /tmp/dummy.log
readelf -l /tmp/a.out | grep ': /lib'    # must show /lib64/ld-linux-x86-64.so.2
rm -v /tmp/dummy.c /tmp/a.out /tmp/dummy.log
cd /sources && rm -rf gcc-*/
```

> Expected interpreter: `[/lib64/ld-linux-x86-64.so.2]`

---

### Steps 26–65 — Core utilities and libraries

These follow the same `./configure --prefix=/usr && make && make install` pattern.
Refer to individual scripts for exact flags. Key notes:

| Step | Package | Note |
|------|---------|------|
| 26 | Ncurses | uses DESTDIR staging + compat symlinks |
| 27 | Sed | |
| 28 | Psmisc | |
| 29 | Gettext | |
| 30 | Bison | |
| 31 | Grep | |
| 32 | Bash | run `exec /usr/bin/bash --login` after to reload |
| 33 | Libtool | |
| 34 | GDBM | |
| 35 | Gperf | |
| 36 | Expat | |
| 37 | Inetutils | |
| 38 | Less | |
| 39 | Perl | must set `BUILD_ZLIB=False BUILD_BZIP2=0` |
| 40 | XML::Parser | |
| 41 | Intltool | |
| 42 | Autoconf | |
| 43 | Automake | |
| 44 | OpenSSL | needed for wget/curl (internet connectivity) |
| 46 | Libelf | |
| 47 | Libffi | `--without-gcc-arch` (no CPU-specific code) |
| 48 | Python | full build (temporary one from Ch.7) |
| — | Flit-core, Packaging, Wheel, Setuptools, Ninja, Meson | Python build tools |
| — | Kmod | Meson-only since kmod 34 → after Meson |
| 49 | Coreutils | requires `FORCE_UNSAFE_CONFIGURE=1` |
| 50 | Check | |
| 51 | Diffutils | |
| 52 | Gawk | |
| 53 | Findutils | |
| 54 | Groff | |
| 55 | GRUB | clear `{C,CPP,CXX,LD}FLAGS` first |
| 56 | Gzip | |
| 57 | IPRoute2 | |
| 58 | Kbd | |
| 59 | Libpipeline | |
| 60 | Make | |
| 61 | Patch | |
| 62 | Tar | requires `FORCE_UNSAFE_CONFIGURE=1` |
| 63 | Texinfo | |
| 64 | Vim | |
| 65 | Man-DB | |

---

### Step 66 — Eudev ⚠️ Subject requirement

The subject requires **Eudev** (udev without systemd) as the kernel module loader.
The `udev-lfs` tarball must be in `/sources`.

```bash
cd /sources && tar -xf eudev-*.tar.gz && cd eudev-*/
./configure --prefix=/usr --bindir=/usr/sbin --sbindir=/usr/sbin \
            --sysconfdir=/etc --enable-manpages --disable-static
make
mkdir -pv /lib/udev/rules.d /etc/udev/rules.d
make check
make install
tar -xf ../udev-lfs-*.tar.xz
make -f udev-lfs-*/Makefile.lfs install
udevadm hwdb --update
cd /sources && rm -rf eudev-*/
```

---

### Step 67 — Man-DB

```bash
cd /sources && tar -xf man-db-*.tar.xz && cd man-db-*/
./configure --prefix=/usr --docdir=/usr/share/doc/man-db \
            --sysconfdir=/etc --disable-setuid            \
            --enable-cache-owner=bin                      \
            --with-browser=/usr/bin/lynx                  \
            --with-vgrind=/usr/bin/vgrind                 \
            --with-grap=/usr/bin/grap
make && make install
cd /sources && rm -rf man-db-*/
```

---

### Step 68 — Procps-ng

```bash
cd /sources && tar -xf procps-*.tar.xz && cd procps-*/
sed -i '/#include "xalloc.h"/a #include <stdbool.h>' src/watch.c
./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-$(cat configure | grep PACKAGE_VERSION= | head -1 | cut -d= -f2 | tr -d "'") \
            --disable-static                         \
            --disable-kill
make && make install
cd /sources && rm -rf procps-*/
```

---

### Step 69 — Util-linux

```bash
cd /sources && tar -xf util-linux-*.tar.xz && cd util-linux-*/
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime
make && make install
cd /sources && rm -rf util-linux-*/
```

---

### Step 70 — E2fsprogs

```bash
cd /sources && tar -xf e2fsprogs-*.tar.gz && cd e2fsprogs-*/
mkdir -v build && cd build
../configure --prefix=/usr      \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck
make && make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
cd /sources && rm -rf e2fsprogs-*/
```

---

### Step 71 — Sysklogd

> **Version note:** LFS 12.4 uses sysklogd **2.6.1** (troglobit rewrite), not the
> old 1.5.1. The `ksym_mod.c`/`union wait` patches only apply to 1.x — skip them.
> Build uses autoconf instead of a bare Makefile.

```bash
cd /sources && tar -xf sysklogd-*.tar.gz && cd sysklogd-*/
./autogen.sh
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --runstatedir=/run
make && make install
cat > /etc/syslog.conf << "EOF"
auth,authpriv.*          -/var/log/auth.log
*.*;auth,authpriv.none   -/var/log/sys.log
daemon.*                 -/var/log/daemon.log
kern.*                   -/var/log/kern.log
mail.*                   -/var/log/mail.log
user.*                   -/var/log/user.log
*.emerg                   *
EOF
cd /sources && rm -rf sysklogd-*/
```

---

### Step 72 — Sysvinit ⚠️ Subject requirement

The subject requires SysV init. This is the last package of the final system.

```bash
cd /sources && tar -xf sysvinit-*.tar.xz && cd sysvinit-*/
for p in ../sysvinit-*-consolidated-*.patch; do
    [ -f "$p" ] && patch -Np1 -i "$p"
done
make && make install
cd /sources && rm -rf sysvinit-*/
```

---

## Post-build sanity check

Run these inside the chroot after step 79:

```bash
# verify core tools are from the LFS system
gcc --version     # your GCC version, not host's
ldd --version     # glibc version
bash --version
python3 --version
perl --version

# verify init system
ls -la /sbin/init       # should point to sysvinit

# verify udev
udevadm --version

# package count sanity
ls /usr/lib/*.so* | wc -l    # should be 100+
```

---

## Build order reference

| # | Package | Depends on |
|---|---------|-----------|
| 1–2 | Man-pages, Iana-Etc | nothing |
| 3 | **Glibc** | Python from Ch.7 (2.39+ hard requirement) |
| 4–6 | Zlib, Bzip2, Xz | Glibc |
| 8–12 | File, Readline, M4, Bc, Flex | Glibc, Ncurses(Readline) |
| 12–14 | Tcl, Expect, DejaGNU | test infrastructure |
| 15–16 | Pkgconf, Binutils | needed before GCC |
| 17–19 | GMP, MPFR, MPC | needed by GCC |
| 20–23 | Attr, Acl, Libcap, Libxcrypt | before Shadow/GCC |
| 24 | **Shadow** ⚠️ interactive | Libxcrypt |
| 25 | **GCC** ⚠️ longest | GMP, MPFR, MPC, Binutils |
| 26–46 | Ncurses → Libelf (core utilities) | GCC |
| 47–48 | Libffi, Python (full) | final Glibc |
| 49–65 | Coreutils → Man-DB | various |
| 66 | **Eudev** | udev-lfs tarball |
| 67–70 | Man-DB, Procps, Util-linux, E2fsprogs | various |
| 71–72 | **Sysklogd, Sysvinit** | must be last |

---

## Troubleshooting

Real issues encountered during this build — not external problems.

---

### `make: Please run make(1) with the '-R' option`

**Package:** Man-pages  
**Cause:** The Man-pages Makefile explicitly forbids built-in make variables.  
**Fix:**
```bash
make -R prefix=/usr install
```

---

### `cannot create directory 'build': File exists`

**Packages:** Glibc, GCC, Binutils, E2fsprogs (any package that uses a build subdir)  
**Cause:** The source tarball was already extracted and built during the cross/temp
tools phase. The `build/` directory is left over.  
**Fix:** Always clear it before creating:
```bash
rm -rf build && mkdir -v build && cd build
```
All scripts in this repo already apply this fix.

---

### `configure: error: python missing or too old` (Glibc)

**Package:** Glibc 2.39+  
**Cause:** Glibc uses Python scripts during `make` to generate internal headers.
Python must exist in the chroot before Glibc can be built.  
**Fix:** Python must come from Chapter 7: run `chroot-tools/26_python.sh`
(or `04_run_chroot_tools.sh 5`). If the Python tarball is missing from `/sources`:
```bash
# exit chroot, run on host as linuxdev
sudo wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz \
     -P /mnt/lfs/sources/
sudo wget https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz \
     -P /mnt/lfs/sources/
```

---

### `libbfd-*.so: file too short` / `error while loading shared libraries`

**Symptom:** `gcc` fails with a shared library loading error, or `as` crashes.  
**Cause:** The strip step (chapter 7 cleanup) crashed mid-write on `libbfd`, truncating
the file. This breaks the assembler which links against it.  
**Detection:**
```bash
ls -lh /usr/lib/libbfd-*.so    # inside chroot: should be ~6 MB, not bytes
```
**Fix (from host as linuxdev — exit chroot first):**
```bash
sudo bash -c '
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export PATH=/mnt/lfs/tools/bin:/usr/local/bin:/usr/bin:/bin
rm -rf $LFS/sources/binutils-2.45
cd $LFS/sources && tar -xf binutils-*.tar.xz && cd binutils-2.45
sed "6009s/\$add_dir//" -i ltmain.sh
mkdir build && cd build
../configure --prefix=/usr --build=$(../config.guess) --host=$LFS_TGT \
    --disable-nls --enable-shared --enable-gprofng=no --disable-werror \
    --enable-64-bit-bfd --enable-new-dtags --enable-default-hash-style=gnu
make && make DESTDIR=$LFS install
cd $LFS/sources && rm -rf binutils-2.45
'
```
Re-enter the chroot and verify: `echo 'int main(){}' | gcc -xc -`  
**Prevention:** The cleanup script (`28_cleanup.sh`) now skips `libbfd` and
`libopcodes` during stripping.

---

### `cannot compute suffix of object files: cannot compile`

**Package:** Glibc (configure fails immediately)  
**Cause:** `gcc` itself is broken — usually the `libbfd` corruption above.  
**Fix:** Test first with `echo 'int main(){}' | gcc -xc -`. If that fails,
fix the assembler/libbfd issue first (see above), then retry the configure.

---

### Host VM boots into initramfs emergency shell

**Symptom:** After a reboot, the host OS drops into a BusyBox shell.  
**Cause:** Host root filesystem failed to mount (not related to LFS build — the
LFS partition is on a separate disk and is unaffected).  
**Fix:**
```bash
# from the initramfs shell
blkid                  # identify host root partition (look for ext4 on /dev/sdaX)
fsck -y /dev/sda2      # replace with your actual host root partition
exit                   # initramfs retries mount and boots normally
```
Once the host is back, remount and re-enter the chroot:
```bash
sudo bash scripts/02_build/03_enter_chroot.sh
```

---

### `x86_64-lfs-linux-gnu-ar: No such file or directory`

**Cause:** Running a cross-compilation step without the cross-tools in PATH.  
**Fix:** The cross-tools live in `/mnt/lfs/tools/bin` on the host. When running
cross-compilation steps as root outside the chroot:
```bash
export PATH=/mnt/lfs/tools/bin:/usr/local/bin:/usr/bin:/bin
```

---

### `sed: can't read ksym_mod.c` / `make: No targets specified` (Sysklogd)

**Cause:** Either (a) the sysklogd tarball is missing from `/sources`, or (b) a
corrupt/wrong-version tarball exists alongside the correct one so the `*` glob
expands to multiple files and tar fails silently, leaving no extracted directory.  
**Detection:**
```bash
ls /sources/sysklogd*
```
**Fix:** Remove any stale tarballs, download 2.6.1 from outside the chroot, then
extract explicitly:
```bash
# outside chroot
wget -P /mnt/lfs/sources \
  https://github.com/troglobit/sysklogd/releases/download/v2.6.1/sysklogd-2.6.1.tar.gz

# inside chroot
rm -f /sources/sysklogd-2.7.2.tar.gz   # remove stale if present
cd /sources && tar -xf sysklogd-2.6.1.tar.gz && cd sysklogd-2.6.1/
```
**Note:** The old `sed` patches (`ksym_mod.c`, `union wait`) are for sysklogd 1.x
only — version 2.6.1 uses `./autogen.sh && ./configure`. See Step 71.

---

### `lfs is not in the sudoers file`

**Cause:** The `lfs` build user has no sudo privileges.  
**Fix:** Use `linuxdev` (the main user with sudo) for any host-side privileged
operations. Only use `lfs` for building inside `$LFS/sources`.

---

**Next:** [10 System Configuration](10_system_config.md) → [11 Kernel and Bootloader](11_kernel_bootloader.md)
