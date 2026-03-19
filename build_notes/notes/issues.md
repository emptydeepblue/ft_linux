# Known Issues and Solutions

## Overview

This document tracks common issues encountered during the ft_linux build and their solutions.

## Build Issues

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
bash scripts/01_setup/00_version_check.sh
```
Should show `OK: sh is Bash` now.

### 3. Package Download Failures
**Problem**: After wget list is generated, some downloads fail due to network issues or mirror problems.
**Solution**:
1. Check wget log for failed URLs
2. Try re-run the wget command to see if it succeeds on retry
3. If still fails, manually download the file from an alternative mirror and place it in the sources directory
4. Update wget list with working URLs
```

