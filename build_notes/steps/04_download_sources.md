# 04 - Downloading LFS Sources

This chapter covers downloading all the source packages and patches required for building the LFS system, verifying their integrity, and cleaning up unnecessary artifacts.

*Table of Contents:*
- [Prerequisites](#prerequisites)
- [Step 1: Fetch the Package List](#step-1-fetch-the-package-list)
- [Step 2: Download All Source Packages](#step-2-download-all-source-packages)
- [Step 3: Verify Checksums](#step-3-verify-checksums)
- [Step 4: Download SysV-Specific Packages](#step-4-download-sysv-specific-packages)
- [Step 5: Remove SystemD-Only Packages](#step-5-remove-systemd-only-packages)
- [Step 6: Clean Up and Verify](#step-6-clean-up-and-verify)

*Scripts*
- [Download sources](../../scripts/01_setup/03_download_sources.sh)

```bash
bash scripts/01_setup/03_download_sources.sh
```

---

## Prerequisites

This step must run as the **lfs user** with `$LFS` set and the partition mounted:

```bash
sudo su - lfs
```

Verify before proceeding:

```bash
whoami          # must print: lfs
echo $LFS       # must print: /mnt/lfs
mountpoint $LFS # must print: /mnt/lfs is a mountpoint
```

> If `$LFS` is empty, run `source ~/.bash_profile` to reload the environment.

---

## Step 1: Fetch the Package List

> The **wget-list-sysv** is maintained by the LFS project and contains URLs for all required source tarballs and patches for a SysV build.

```bash
cd $LFS/sources
wget -q --show-progress \
    https://www.linuxfromscratch.org/lfs/downloads/12.4/wget-list-sysv \
    -O wget-list-sysv
```

---

## Step 2: Download All Source Packages

```bash
wget --input-file=wget-list-sysv \
     --continue \
     --directory-prefix=$LFS/sources \
     2>&1 | tee wget_errors.log
```

Check for failures:

```bash
grep -qi "ERROR\|failed\|404\|unable" wget_errors.log && echo "WARNING: some downloads failed — check wget_errors.log" || echo "All downloads OK."
```

> If some files fail, refer to [Package Download Failures](../notes/issues.md#2-package-download-failures).

---

## Step 3: Verify Checksums

```bash
wget -q https://www.linuxfromscratch.org/lfs/downloads/12.4/md5sums \
    -O $LFS/sources/md5sums

pushd $LFS/sources > /dev/null
FAILED=$(md5sum -c md5sums 2>&1 | grep FAILED | wc -l)
if [ "$FAILED" -gt 0 ]; then
    echo "WARNING: $FAILED checksum(s) failed:"
    md5sum -c md5sums 2>&1 | grep FAILED
    echo "Re-download the failed files and re-run."
else
    echo "All checksums OK."
fi
popd > /dev/null
```

---

## Step 4: Download SysV-Specific Packages

These are not in the wget-list but are required for a SysV build:

```bash
cd $LFS/sources

# Check — unit testing framework (required for Glibc test suite)
wget -qc --show-progress \
    https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz

# Eudev — udev replacement for SysV (required for kernel module loading / device management)
wget -qc --show-progress \
    https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz
```

---

## Step 5: Remove SystemD-Only Packages

These packages are not needed for a SysV build:

```bash
cd $LFS/sources

rm -fv \
    dbus-*.tar.*              \
    elfutils-*.tar.*         \
    flit_core-*.tar.*         \
    jinja2-*.tar.*            \
    libxcrypt-*.tar.*         \
    markupsafe-*.tar.*        \
    meson-*.tar.*             \
    ninja-*.tar.*             \
    openssl-*.tar.*           \
    packaging-*.tar.*         \
    python-*-docs-*.tar.*    \
    Python-*.tar.*            \
    setuptools-*.tar.*        \
    systemd-*.tar.*           \
    systemd-man-pages-*.tar.* \
    zstd-*.tar.*              \
    2>/dev/null || true
```

---

## Step 6: Clean Up and Verify

### 6.1 Remove download artifacts

```bash
rm -f $LFS/sources/wget-list-sysv \
      $LFS/sources/md5sums \
      $LFS/sources/wget_errors.log
```

### 6.2 Summary

```bash
echo "Tarballs downloaded : $(ls $LFS/sources/*.tar.* 2>/dev/null | wc -l)"
echo "Disk used           : $(du -sh $LFS/sources | cut -f1)"
```

### 6.3 Cross-toolchain tarballs check

Verify the 7 tarballs the cross-toolchain needs most are present:

```bash
for name in binutils gcc linux glibc mpfr gmp mpc; do
    f=$(ls $LFS/sources/$name-*.tar.* 2>/dev/null | head -1)
    if [ -n "$f" ]; then
        printf "  OK      : %s\n" "$(basename $f)"
    else
        printf "  MISSING : %s\n" "$name"
    fi
done
```

---

**Next:** [05 Toolchain Build](05_toolchain.md)
