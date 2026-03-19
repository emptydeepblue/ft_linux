# 02 Disk Partitioning

This document provides instructions for partitioning the disk for a Linux From Scratch (LFS) build. Proper disk partitioning is essential for organizing the file system and ensuring that the LFS build process runs smoothlys.

*Table of Contents:*
- [1 Partition the LFS disk](#1-partition-the-lfs-disk)
- [2 Format the partitions](#2-format-the-partitions)
- [3 Mount the LFS partitions](#3-mount-the-lfs-partitions)
- [4 Make mounts persistent across reboots](#4-make-mounts-persistent-across-reboots)

*Scripts*
- [disk partition](../../scripts/01_setup/01_disk_partition.sh)

```bash
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdbs
```
### 1 Partition the LFS disk

```bash
sudo fdisk /dev/sdb
```

Inside `fdisk`, create three partitions:

| Command sequence | Result |
|---|---|
| `n` → `p` → `1` → Enter → `+500M` | Partition 1: LFS `/boot` (500 MB) |
| `n` → `p` → `2` → Enter → `+2G` | Partition 2: LFS swap (2 GB) |
| `n` → `p` → `3` → Enter → Enter | Partition 3: LFS `/` root (remaining ~27.5 GB) |
| `t` → `2` → `82` | Set partition 2 type to Linux swap |
| `w` | Write partition table and exit |

Verify:
```bash
lsblk /dev/sdb
```
Expected:
```
sdb      30G
├─sdb1  500M    ← LFS /boot
├─sdb2    2G    ← LFS swap
└─sdb3 27.5G    ← LFS / (root)
```

### 2 Format the partitions

```bash
sudo mkfs.ext4 /dev/sdb1       # LFS /boot
sudo mkswap    /dev/sdb2       # LFS swap
sudo mkfs.ext4 /dev/sdb3       # LFS / (root)
```

### 3 Mount the LFS partitions

```bash
export LFS=/mnt/lfs

# Mount root FIRST, then boot inside it
sudo mkdir -pv $LFS
sudo mount -v -t ext4 /dev/sdb3 $LFS

sudo mkdir -pv $LFS/boot
sudo mount -v -t ext4 /dev/sdb1 $LFS/boot

# Enable swap
sudo swapon -v /dev/sdb2
```

### 4 Make mounts persistent across reboots

```bash
sudo bash -c 'cat >> /etc/fstab << "EOF"

# LFS partitions (second virtual disk)
/dev/sdb3  /mnt/lfs       ext4  defaults  0  2
/dev/sdb1  /mnt/lfs/boot  ext4  defaults  0  2
/dev/sdb2  none           swap  sw        0  0
EOF'
```

Verify:
```bash
mount | grep lfs
swapon --show
```
