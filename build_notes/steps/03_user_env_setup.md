# 03 LFS Environment Setup

This chapter covers setting up the LFS build environment, including creating the full directory layout, a dedicated build user, and the shell environment needed for cross-compilation.

*Table of Contents:*
- [Prerequisites](#prerequisites)
- [Step 1: Create the Directory Layout](#step-1-create-the-directory-layout)
- [Step 2: Create the LFS User](#step-2-create-the-lfs-user)
- [Step 3: Set Ownership](#step-3-set-ownership)
- [Step 4: Set Up the Shell Environment](#step-4-set-up-the-shell-environment)
- [Step 5: Verify](#step-5-verify)

*Scripts*
- [LFS environment setup](../../scripts/01_setup/02_env_setup.sh)

```bash
sudo bash scripts/01_setup/02_env_setup.sh
```

---

## Prerequisites

Ensure `$LFS` is set and both partitions are mounted:

```bash
export LFS=/mnt/lfs
mountpoint -q $LFS && echo "ok" || echo "ERROR: $LFS not mounted"
mountpoint -q $LFS/boot && echo "ok" || echo "ERROR: $LFS/boot not mounted"
```

> If either check fails, go back to [02 Disk Partitioning](02_disk_paritioning.md) and remount.

---

## Step 1: Create the Directory Layout

> Run all commands in this step as **root** (or with `sudo`). Do not switch to the `lfs` user yet.

```bash
# sources: sticky + world-writable so any user can add tarballs
sudo mkdir -pv $LFS/sources
sudo chmod -v  a+wt $LFS/sources

# tools: cross-toolchain destination
sudo mkdir -pv $LFS/tools

# standard FHS directories
sudo mkdir -pv $LFS/etc $LFS/var
sudo mkdir -pv $LFS/usr/bin $LFS/usr/lib $LFS/usr/sbin

# unified layout: bin, lib, sbin are symlinks into usr/
for i in bin lib sbin; do
    sudo ln -sfv usr/$i $LFS/$i
done

# x86_64: lib64 for the ELF interpreter*
case $(uname -m) in
    x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac
```
*INFO ELF interpreter:*

---

## Step 2: Create the LFS User

> The `lfs` user builds the cross-toolchain (Chapters 5–6) without root privileges, preventing accidental damage to the host system.

```bash
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs
```

---

## Step 3: Set Ownership

Give the `lfs` user write access to all LFS directories:

```bash
sudo chown -v lfs $LFS/tools $LFS/sources
sudo chown -v lfs $LFS/usr $LFS/usr/bin $LFS/usr/lib $LFS/usr/sbin
sudo chown -v lfs $LFS/lib $LFS/var $LFS/etc $LFS/bin $LFS/sbin $LFS/boot

case $(uname -m) in
    x86_64) sudo chown -v lfs $LFS/lib64 ;;
esac
```

---

## Step 4: Set Up the Shell Environment

Write the environment files directly into `/home/lfs/` as root, then fix ownership:

### 4.1 `.bash_profile`

> `exec env -i` starts a completely clean shell so no inherited host environment variables can interfere with cross-compilation.

```bash
sudo bash -c 'cat > /home/lfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='"'"'\u:\w\$ '"'"' /bin/bash
EOF'
```

### 4.2 `.bashrc`

> .bashrc — sets all variables needed for cross-compilation

> **Explanation of environment variables:**
> - `set +h` — disables bash's hash function so newly built tools are always found via PATH lookup
> - `umask 022` — new files are readable by everyone, writable only by owner
> - `LFS` — mount point of the LFS partition
> - `LC_ALL=POSIX` — consistent locale to avoid encoding issues
> - `LFS_TGT` — target triplet for cross-compilation (e.g., `x86_64-lfs-linux-gnu`)
> - `PATH` — `$LFS/tools/bin` first so cross-compiled tools take precedence; `/usr/bin` and `/bin` for host tools
> - `CONFIG_SITE` — default options for configure scripts
> - `MAKEFLAGS` — parallel compilation using all CPU cores

```bash
sudo bash -c 'cat > /home/lfs/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=$LFS/tools/bin:/usr/bin:/bin
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS=-j$(nproc)
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF'
```

### 4.3 Fix ownership

```bash
sudo chown lfs:lfs /home/lfs/.bash_profile /home/lfs/.bashrc
```

---

## Step 5: Verify

### 5.1 Directory layout

```bash
ls -la $LFS/
```

Expected:
```
bin -> usr/bin
boot/
etc/
lib -> usr/lib
lib64/
sbin -> usr/sbin
sources/
tools/
usr/
var/
```

### 5.2 Ownership (should all be `lfs`)

```bash
stat -c "%U:%G %n" $LFS/tools $LFS/sources $LFS/usr
```

### 5.3 Shell environment

Switch to the lfs user and verify:

```bash
sudo su - lfs
echo $LFS        # /mnt/lfs
echo $LFS_TGT    # x86_64-lfs-linux-gnu
echo $PATH       # /mnt/lfs/tools/bin:/usr/bin:/bin
which make       # /usr/bin/make
which gcc        # /usr/bin/gcc
exit
```

---

**Next:** [04 Download Sources](04_download_sources.md)
