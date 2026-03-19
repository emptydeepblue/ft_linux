# 04 - Downloading LFS Sources

This chapter covers downloading all the source packages and patches required for building the LFS system. It also includes verifying the integrity of the downloaded files and cleaning up any unnecessary artifacts.

*Table of Contents:*
- [Step 1: Download LFS Sources](#step-1-download-lfs-sources)
- [Step 2: Finalize the Setup](#step-2-finalize-the-setup)

*Scripts*
- [Dowload sources](../../scripts/setup/03_download_sources.sh)

```bash
bash scripts/setup/03_download_sources.sh
```

## Step 1: Download LFS Sources

Switch to the lfs user:
```bash
sudo su - lfs
```

### 1.1 Download all source packages

🔍 The **wget-list** is maintained by the LFS project and contains URLs for all required source tarballs and patches.

```bash
cd $LFS/sources
wget https://www.linuxfromscratch.org/lfs/downloads/12.2/wget-list-sysv
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources 2>&1 | tee wget_errors.log
```
> ⚠️ Use `wget-list-sysv` (not the default which may include SystemD packages). If some files fail to download, refer to [Package Download Failures](issues.md#2-package-download-failures).

### 1.2 Verify checksums

```bash
wget https://www.linuxfromscratch.org/lfs/downloads/12.2/md5sums -P $LFS/sources
pushd $LFS/sources
md5sum -c md5sums 2>&1 | tee md5_verification.log
popd
```

### 1.3 Download missing SysV-specific packages

These may not be in the wget-list but are required for a SysV (non-SystemD) build:

```bash
cd $LFS/sources

# Check (unit test framework)
wget https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz

# Eudev (udev replacement for SysV — required for kernel module loading)
wget https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz

# LFS Bootscripts (init scripts for SysV)
wget https://www.linuxfromscratch.org/lfs/downloads/12.2/lfs-bootscripts-20240825.tar.xz
```
> ⚠️ Adjust version numbers to match your LFS book version.

### 1.4 Remove unnecessary SystemD packages (optional, saves space)

Since we're building a SysV system, these are not needed:

```bash
cd $LFS/sources
rm -vf dbus-*.tar.gz
rm -vf elfutils-*.tar.bz2
rm -vf flit_core-*.tar.gz
rm -vf jinja2-*.tar.gz
rm -vf libxcrypt-*.tar.xz
rm -vf markupsafe-*.tar.gz
rm -vf meson-*.tar.gz
rm -vf ninja-*.tar.gz
rm -vf openssl-*.tar.gz
rm -vf packaging-*.tar.gz
rm -vf python-*-docs-*.tar.bz2
rm -vf Python-*.tar.xz
rm -vf setuptools-*.tar.gz
rm -vf systemd-*.tar.gz
rm -vf systemd-man-pages-*.tar.xz
rm -vf zstd-*.tar.gz
```

### 1.5 Clean up download artifacts

```bash
rm -f $LFS/sources/{wget-list*,md5sums,wget_errors.log,md5_verification.log}
```

---

## Step 2: Finalize the Setup

### 2.1 Final ownership check

```bash
exit  # back to everonel
export LFS=/mnt/lfs

sudo chown -R lfs:lfs $LFS/sources
sudo chown -R lfs:lfs $LFS/tools
```
### 2.2 Verify everything
Switch to lfs and run these checks:

```bash
sudo su - lfs

echo "=== Environment ==="
echo "LFS=$LFS"
echo "LFS_TGT=$LFS_TGT"
echo "PATH=$PATH"
echo "MAKEFLAGS=$MAKEFLAGS"

echo "=== Host tools ==="
which make gcc g++ ld bison gawk m4 tar

echo "=== LFS disk ==="
df -h $LFS $LFS/boot
swapon --show

echo "=== LFS directory structure ==="
ls -la $LFS/

echo "=== Sources count ==="
ls $LFS/sources/*.tar.* | wc -l
```
