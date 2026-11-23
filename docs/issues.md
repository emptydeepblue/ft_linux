# Known Issues and Solutions

## Overview

This document tracks common issues encountered during the ft_linux build and their solutions.

## Build Issues

### 0b. Glibc sanity check failed on a correct toolchain (2026-11-23)
**Problem**: `5.05_glibc.sh` stopped with *FATAL: interpreter is '[Requesting
program interpreter: /lib64/ld-linux-x86-64.so.2]', expected
'[/lib64/ld-linux-x86-64.so.2]'*. The interpreter was right: the check cut the
`readelf` line with `grep -o '\[.*\]'`, which keeps the whole bracket text.
**Solution**: the check now only tests that the line ends with
`: /lib64/ld-linux-x86-64.so.2]` (tested on the real line and on a wrong one).
Glibc had been fully installed (the check is its last step), so the build
resumed at 5.6.

### 0c. Resuming after a failure: leftover source directory
**Problem**: a failed step leaves `$LFS/sources/<package>-<version>/` behind;
re-running it then stops at `mkdir build` ("File exists").
**Solution**: every package script removes its own leftover directory before
unpacking (`rm -rf <package>-*/`), so `run.sh <section>` always restarts clean.

### 0. A source URL of the book is gone (ncurses, 2026-11-23)
**Problem**: `https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20250809.tgz`
returned *404*: the `current/` directory only keeps the latest snapshots. Worse,
`04_download_sources.sh` stopped right there (`set -o pipefail` + the failing
`wget | tee`), so the extra packages were never downloaded and only a WARNING
had been planned for bad checksums.
**Solution**: the script now goes on after a failed download, retries every
missing or wrong file from the LFS package archive
(`LFS_MIRROR=https://ftp.osuosl.org/pub/lfs/lfs-packages/12.4`, same md5), and
fails at the end with the list of files still unusable.
First version of that fix stopped silently at "Verifying checksums": `md5sum -c`
exits 1 when a file is bad, and inside `$( … | awk …)` with `set -e` +
`pipefail` that ended the script. Fixed with `{ md5sum -c … || true; } | awk`:
in this function a failing check is the expected case, not an error.

### 1. DNS issues on host distribution (Ubuntu Server 22.04)
**Problem**: Unable to resolve domain names, causing package downloads to fail.
**Solution**:
```bash
sudo systemctl disable --now systemd-resolved
sudo rm -f /etc/resolv.conf
printf 'nameserver 8.8.8.8\nnameserver 1.1.1.1\n' | sudo tee /etc/resolv.conf
sudo chattr -i /etc/resolv.conf
sudo reboot
```

### 2. sh is NOT Bash
issue is sh is NOT Bash — on Ubuntu, /bin/sh points to dash by default. Fix it:

```bash
sudo ln -sf bash /bin/sh
Then verify:
bash build/1_host/02_version_check.sh
```
Should show `OK: sh is Bash` now.

### 3. Package Download Failures
**Problem**: After wget list is generated, some downloads fail due to network issues or mirror problems.
**Solution**:
1. Check wget log for failed URLs
2. If many packages failed try re-run the wget command to see if it succeeds on retry
3. If just some of them fails, manually download the file from alternative mirrors like: 
- from GNU ftp
*example*
```bash
wget -c --show-progress \
    https://ftp.gnu.org/gnu/<tool>/<tool>-<version>.tar.xz \
    -P $LFS/sources
```
- directly from the tool https mirrors
*example*
```bash
wget -c --show-progress \
    https://www.<tool>.org/<tool>-<version>/<tool>-<version>.tar.xz \
    -P $LFS/sources
```
4. Update wget list with working URLs

