# Chroot Setup and Additional Temporary Tools — ft_linux

This chapter has two distinct phases with **different users and environments**.
Read the context column carefully before running anything.

| Phase | Where | Who | Script |
|-------|-------|-----|--------|
| 1 – Ownership + mounts | Host | `root` | `03_enter_chroot.sh` |
| 2 – Dirs, files, packages | Inside chroot | `root` (chroot) | `04_run_chroot_tools.sh` |

---

## Quick run (automated)

**On the host as root** — transfers ownership, mounts VKFSs, enters chroot:
```bash
sudo bash scripts/02_build/03_enter_chroot.sh
```

**Inside the chroot** — builds all 8 steps (setup + packages 23–29):
```bash
bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh

# resume from step N after a failure
bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh <N>
```

> The scripts and `config/` are already inside the chroot at `/sources/ft_linux/` (same layout as the repo) because
> `03_enter_chroot.sh` runs `scripts/sync_to_lfs.sh` before entering.

Individual scripts (run inside chroot, in order):
- [00_setup_dirs.sh](../../scripts/02_build/chroot-tools/00_setup_dirs.sh)
- [23_gettext.sh](../../scripts/02_build/chroot-tools/23_gettext.sh)
- [24_bison.sh](../../scripts/02_build/chroot-tools/24_bison.sh)
- [25_perl.sh](../../scripts/02_build/chroot-tools/25_perl.sh)
- [26_python.sh](../../scripts/02_build/chroot-tools/26_python.sh)
- [27_texinfo.sh](../../scripts/02_build/chroot-tools/27_texinfo.sh)
- [28_util_linux.sh](../../scripts/02_build/chroot-tools/28_util_linux.sh)
- [29_cleanup.sh](../../scripts/02_build/chroot-tools/29_cleanup.sh)

---

## Manual run (step by step)

---

### Phase 1 — Host preparation (as root)

#### Step A — Transfer ownership

During the toolchain build every file under `$LFS` was owned by the `lfs` user.
The final system must be owned by `root`.

```bash
# still on the host
sudo su -

LFS=/mnt/lfs

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools,sources}
# x86_64 only:
chown -R root:root $LFS/lib64
```

#### Step B — Mount virtual kernel filesystems

These pseudo-filesystems expose kernel information to processes inside the chroot.
They must be remounted after every reboot before re-entering.

```bash
mkdir -pv $LFS/{dev,proc,sys,run}

# /dev — bind-mount from host so device nodes exist immediately
mount -v --bind /dev $LFS/dev

# /dev/pts — pseudo-terminals
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts

# /proc — kernel process information
mount -vt proc proc $LFS/proc

# /sys — kernel device/driver information
mount -vt sysfs sysfs $LFS/sys

# /run — runtime data (tmpfs, wiped on reboot)
mount -vt tmpfs tmpfs $LFS/run

# /dev/shm — shared memory
if [ -h $LFS/dev/shm ]; then
    install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
    mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
```

Verify all are mounted:
```bash
findmnt | grep $LFS
```

Expected output includes entries for `/dev`, `/dev/pts`, `/proc`, `/sys`, `/run`.

#### Step C — Copy build scripts into $LFS

```bash
sudo bash scripts/sync_to_lfs.sh   # copies scripts/ + config/ to $LFS/sources/ft_linux
```

#### Step D — Enter the chroot

```bash
chroot "$LFS" /usr/bin/env -i       \
    HOME=/root                       \
    TERM="$TERM"                     \
    PS1='(lfs chroot) \u:\w\$ '     \
    PATH=/usr/bin:/usr/sbin          \
    MAKEFLAGS="-j$(nproc)"           \
    /usr/bin/bash --login
```

Your prompt changes to `(lfs chroot) root:/# `. You are now inside the LFS system.

> **Re-entering after reboot:** repeat steps B–D. The ownership transfer (step A)
> only needs to be done once.

---

### Phase 2 — Inside the chroot

All remaining commands in this chapter run **inside the chroot** as root.
There is no `sudo` — you are already root within the isolated environment.

---

### Step 0 — Create directory layout and essential files

Creates the full FHS directory tree, `/etc/passwd`, `/etc/group`, log files,
and a minimal login environment.

```bash
bash /sources/ft_linux/scripts/02_build/chroot-tools/00_setup_dirs.sh
```

Or manually:

```bash
# ── Directory tree ────────────────────────────────────────────────────────────
mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

# ── Essential files ───────────────────────────────────────────────────────────
ln -sv /proc/self/mounts /etc/mtab

cat > /etc/hosts << EOF
127.0.0.1  localhost
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

# ── Log files ─────────────────────────────────────────────────────────────────
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
```

---

### Step 23 — Gettext (temporary)

Only three binaries are needed at this stage: `msgfmt`, `msgmerge`, `xgettext`.
The full Gettext package is built natively in Chapter 8.

```bash
cd /sources
tar -xf gettext-*.tar.xz
cd gettext-*/

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf gettext-*/
```

---

### Step 24 — Bison

Parser generator required by several Chapter 8 packages (GCC, Glibc, etc.).

```bash
cd /sources
tar -xf bison-*.tar.xz
cd bison-*/

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-$(cat version)

make
make install

cd /sources
rm -rf bison-*/
```

---

### Step 25 — Perl

Scripting runtime required by Autoconf, Automake, and others. Configure flags
set library paths inside the LFS Perl directory tree rather than using FHS defaults.

```bash
cd /sources
tar -xf perl-*.tar.xz
cd perl-*/

# derive minor version from directory (e.g. perl-5.40.0 → 5.40)
PERL_VER=$(basename $(pwd) | sed 's/perl-//')
PERL_MINOR=$(echo $PERL_VER | sed 's/\.[0-9]*$//')

sh Configure -des                                                       \
             -D prefix=/usr                                             \
             -D vendorprefix=/usr                                       \
             -D privlib=/usr/lib/perl5/${PERL_MINOR}/core_perl          \
             -D archlib=/usr/lib/perl5/${PERL_MINOR}/core_perl          \
             -D sitelib=/usr/lib/perl5/${PERL_MINOR}/site_perl          \
             -D sitearch=/usr/lib/perl5/${PERL_MINOR}/site_perl         \
             -D vendorlib=/usr/lib/perl5/${PERL_MINOR}/vendor_perl      \
             -D vendorarch=/usr/lib/perl5/${PERL_MINOR}/vendor_perl

make
make install

cd /sources
rm -rf perl-*/
```

---

### Step 26 — Python (temporary)

Glibc and several Chapter 8 packages run Python at build time (LFS 12.4 §7.10).
The full Python (libffi, expat, optimizations) is rebuilt in Chapter 8.

```bash
cd /sources && tar -xf Python-*.tar.xz && cd Python-*/
./configure --prefix=/usr                   --enable-shared                 --without-ensurepip             --without-static-libpython
make && make install      # warnings about unbuildable modules (ssl, ...) are expected
cd /sources && rm -rf Python-*/
```

---

### Step 27 — Texinfo

Documentation system. Required by binutils, GCC, and others during their install.

```bash
cd /sources
tar -xf texinfo-*.tar.xz
cd texinfo-*/

./configure --prefix=/usr

make
make install

cd /sources
rm -rf texinfo-*/
```

---

### Step 28 — Util-linux

Miscellaneous system utilities (`mount`, `fdisk`, `lsblk`, `kill`, etc.).
Several are disabled because shadow handles login/su in the final system.

```bash
cd /sources
tar -xf util-linux-*.tar.xz
cd util-linux-*/

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib                             \
            --runstatedir=/run                            \
            --disable-chfn-chsh                           \
            --disable-login                               \
            --disable-nologin                             \
            --disable-su                                  \
            --disable-setpriv                             \
            --disable-runuser                             \
            --disable-pylibmount                          \
            --disable-static                              \
            --disable-liblastlog2                         \
            --without-python                              \
            ADJTIME_PATH=/var/lib/hwclock/adjtime         \
            --docdir=/usr/share/doc/util-linux-$(cat .tarball-version)

make
make install

cd /sources
rm -rf util-linux-*/
```

---

### Step 29 — Strip and clean

Removes debug symbols, `.la` files, and cross-compiler `include-fixed` headers.
Reclaims roughly 1 GB before the final build.

```bash
# strip binaries
find /usr/{lib,libexec} -name \*.so* -type f \
    -exec strip --strip-unneeded {} \; 2>/dev/null || true

find /usr/{bin,sbin} -type f \
    -exec strip --strip-all {} \; 2>/dev/null || true

# remove libtool archives
find /usr/{lib,libexec} -name \*.la -delete

# remove cross-compiler include-fixed headers
GCC_VER=$(ls /usr/lib/gcc)
GCC_TGT=$(ls /usr/lib/gcc/$GCC_VER)
rm -rf /usr/lib/gcc/$GCC_VER/$GCC_TGT/include-fixed

# remove documentation (will be rebuilt in Ch.8)
rm -rf /usr/share/{info,man,doc}/*
```

---

## Sanity check before Chapter 8

Verify the chroot environment is healthy:

```bash
# bash and core tools come from the LFS tree, not the host
type bash      # should show /usr/bin/bash
type ls        # should show /usr/bin/ls
gcc --version  # should show your GCC version
perl --version # should show your Perl version

# check /sources is populated
ls /sources/*.tar.*  | wc -l   # should be 60+
```

---

## After a reboot — re-entering the chroot

The VKFSs are not persistent. Run this every time before re-entering:

```bash
# on host, as root
LFS=/mnt/lfs
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc  proc  $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

chroot "$LFS" /usr/bin/env -i       \
    HOME=/root TERM="$TERM"          \
    PS1='(lfs chroot) \u:\w\$ '     \
    PATH=/usr/bin:/usr/sbin          \
    MAKEFLAGS="-j$(nproc)"           \
    /usr/bin/bash --login
```

Or just use `03_enter_chroot.sh` — it is idempotent (safe to run multiple times).

---

## Build order reference

| # | Package | Why |
|---|---------|-----|
| 0 | **Dir + file setup** | FHS layout, passwd/group, log files |
| 23 | **Gettext** | `msgfmt`/`msgmerge`/`xgettext` needed by Ch.8 |
| 24 | **Bison** | parser generator — GCC, Glibc, others |
| 25 | **Perl** | required by Autoconf, Automake, XML::Parser |
| 26 | **Python** | needed at build time by Glibc and others in Ch.8 |
| 27 | **Texinfo** | `makeinfo` needed during install of several packages |
| 28 | **Util-linux** | `mount`, `fdisk`, `lsblk`, hardware clock |
| 29 | **Strip + clean** | reclaim disk space before Chapter 8 |

**Next:** [09 Final System — Chapter 8](09_final_system.md)
