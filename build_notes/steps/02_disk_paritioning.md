# 02 Disk Partitioning

This document covers partitioning, formatting, and mounting the second virtual disk (`/dev/sdb`) that will hold the LFS system.

> **Before starting:** You must be logged into the **host OS** (installed on `/dev/sda`). The ISO is still attached but not needed — leave it for now.

*Table of Contents:*
- [Prerequisites](#prerequisites)
- [1 Verify the second disk](#1-verify-the-second-disk)
- [2 Partition the disk](#2-partition-the-disk)
- [3 Format the partitions](#3-format-the-partitions)
- [4 Mount the partitions](#4-mount-the-partitions)
- [5 Make mounts persistent across reboots](#5-make-mounts-persistent-across-reboots)
- [6 Remove the ISO from VirtualBox](#6-remove-the-iso-from-virtualbox)

*Scripts*
- [disk partition](../../scripts/01_setup/01_disk_partition.sh)

```bash
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdb
```

---

## Prerequisites

Set the `LFS` variable — you will need it in every step below:

```bash
export LFS=/mnt/lfs
```

> This only lasts for the current shell session. Re-run it if you open a new terminal.

---

## 1 Verify the second disk

Confirm that `/dev/sdb` (the empty LFS disk added in VirtualBox) is visible:

```bash
lsblk
```

Expected:
```
sda      30G   ← Host OS disk
├─sda1   ...
└─sda2   ...
sdb      30G   ← LFS disk (empty, no partitions yet)
```

> If the disk is not visible, shut down the VM and verify the second disk is attached in **VirtualBox → Settings → Storage**.

---

## 2 Partition the disk

```bash
sudo fdisk /dev/sdb
```

Inside `fdisk`, run these commands in order:

| Command sequence | Result |
|---|---|
| `n` → `p` → `1` → Enter → `+500M` | Partition 1: LFS `/boot` (500 MB) |
| `n` → `p` → `2` → Enter → `+2G` | Partition 2: swap (2 GB) |
| `n` → `p` → `3` → Enter → Enter | Partition 3: LFS `/` root (remaining space) |
| `t` → `2` → `82` | Set partition 2 type to Linux swap |
| `w` | Write and exit |

Verify:
```bash
lsblk /dev/sdb
```

Expected:
```
sdb      30G
├─sdb1  500M    ← LFS /boot
├─sdb2    2G    ← swap
└─sdb3 27.5G    ← LFS / (root)
```

---

## 3 Format the partitions

```bash
sudo mkfs.ext4 -F -L "lfs-boot" /dev/sdb1   # LFS /boot
sudo mkswap       -L "lfs-swap" /dev/sdb2   # swap
sudo mkfs.ext4 -F -L "lfs-root" /dev/sdb3   # LFS / (root)
```

---

## 4 Mount the partitions

```bash
# Mount root FIRST, then boot inside it
sudo mkdir -pv $LFS
sudo mount -v -t ext4 /dev/sdb3 $LFS

sudo mkdir -pv $LFS/boot
sudo mount -v -t ext4 /dev/sdb1 $LFS/boot

# Enable swap
sudo swapon -v /dev/sdb2
```

Verify:
```bash
mount | grep lfs
swapon --show
df -h $LFS $LFS/boot
```

---

## 5 Make mounts persistent across reboots

```bash
sudo bash -c 'cat >> /etc/fstab << "EOF"

# LFS partitions (second virtual disk)
LABEL=lfs-root  /mnt/lfs       ext4  defaults  0  2
LABEL=lfs-boot  /mnt/lfs/boot  ext4  defaults  0  2
LABEL=lfs-swap  none           swap  sw        0  0
EOF'
```

> After a reboot the partitions will auto-mount, but you will still need to re-run `export LFS=/mnt/lfs` in your shell. This is handled in the next step.

---

## 6 Remove the ISO from VirtualBox

Now that the LFS partitions are set up and the host OS mounts are persistent, you can safely remove the ISO:

1. **Shut down the VM** (or do this while it's running — VirtualBox allows it).
2. Go to **Settings → Storage**.
3. Click on the optical drive entry under the controller.
4. Click the disk icon on the right → **Remove Disk from Virtual Drive**.
5. Start the VM. It will now boot directly from `/dev/sda` (the host OS).

> If the VM fails to boot after removing the ISO, go to **Settings → System → Boot Order** and make sure **Hard Disk** is above **Optical**.

---

**Next:** [03 Environment Setup](03_user_env_setup.md)

## Resources
[script](../../scripts/01_setup/01_disk_partition.sh)
