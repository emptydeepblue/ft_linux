# Virtual Machine Configuration

## Overview

This document describes the virtual machine setup for ft_linux.

## VM Software

Recommended options:
- **VirtualBox** (free, cross-platform)
- **VMWare Workstation/Fusion** (paid, good performance)
- **QEMU/KVM** (advanced, good for Linux hosts)

## System Requirements

### Host System
- At least 4GB RAM (8GB recommended)
- 20GB free disk space minimum
- CPU with virtualization support (VT-x/AMD-V)
- Internet connection

### VM Specifications

**Recommended Settings:**
- **RAM**: 2GB minimum (4GB recommended)
- **CPU**: 2 cores (or more)
- **Disk**: 20GB (dynamic or fixed)
- **Network**: NAT or Bridged
- **Boot Order**: Hard Disk, CD-ROM

## Disk Partitioning

### Partition Scheme

Minimum 3 partitions required:

| Partition | Mount Point | Size | Type | Filesystem |
|-----------|-------------|------|------|------------|
| /dev/sda1 | /boot | 500MB | Primary | ext2/ext4 |
| /dev/sda2 | / | 18GB | Primary | ext4 |
| /dev/sda3 | swap | 2GB | Primary | swap |

### Partition Commands

```bash
# Using fdisk
fdisk /dev/sda

# Create partitions:
# n -> new partition
# p -> primary
# Enter partition number and sizes
# w -> write changes

# Format partitions
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3

# Activate swap
swapon /dev/sda3
```
## VirtualBox Specific Settings

### Creating the VM

```bash
# Command line creation (optional)
VBoxManage createvm --name "ft_linux" --ostype Linux_64 --register

# Set memory
VBoxManage modifyvm "ft_linux" --memory 2048

# Create disk
VBoxManage createhd --filename "ft_linux.vdi" --size 20000

# Add storage controller
VBoxManage storagectl "ft_linux" --name "SATA Controller" --add sata

# Attach disk
VBoxManage storageattach "ft_linux" --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd --medium "ft_linux.vdi"

# Network
VBoxManage modifyvm "ft_linux" --nic1 nat
```

### Guest Additions (Optional for Bonus)

For better integration:
```bash
# Mount guest additions
mount /dev/cdrom /mnt

# Install dependencies (in guest)
cd /mnt
./VBoxLinuxAdditions.run
```

## Initial Boot Process

### Build System

1. **Boot from Live CD/USB**
   - Use any Linux live environment
   - Recommended: Debian, Ubuntu live, or LFS LiveCD

2. **Partition the disk**
   - Follow partition scheme above

3. **Mount partitions**
   ```bash
   export LFS=/mnt/lfs
   mkdir -pv $LFS
   mount /dev/sda2 $LFS
   mkdir -pv $LFS/boot
   mount /dev/sda1 $LFS/boot
   ```

4. **Begin LFS build**
   - Follow LFS book from chapter 5 onwards

## Network Configuration

### During Build

```bash
# Check network in live environment
ip addr
ping -c 3 google.com
```

### In Final System

Network setup in the built system:

```bash
# Static IP (if needed)
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.100
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

# Or use DHCP
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=dhclient
DHCP_START=""
DHCP_STOP=""
EOF
```

## Hostname Configuration

Set hostname to student login:

```bash
echo "<student_login>" > /etc/hostname

# Also update /etc/hosts
cat > /etc/hosts << "EOF"
127.0.0.1 localhost
127.0.1.1 <student_login>
::1       localhost
EOF
```

## BIOS/UEFI Settings

### VirtualBox
- Boot order: Hard Disk first
- Enable EFI if using UEFI boot (optional)
- Enable PAE/NX

### VMWare
- Similar settings in VM configuration

## Storage Optimization

### VirtualBox
```bash
# Compact VDI (from host, VM must be off)
VBoxManage modifymedium disk "ft_linux.vdi" --compact
```

## Snapshot Management

Take snapshots at key points:
1. After partitioning
2. After base system build
3. After kernel compilation
4. Before testing configurations

```bash
# VirtualBox snapshot
VBoxManage snapshot "ft_linux" take "BaseSystem" --description "Base system complete"
```

## Generating Checksum

After final configuration:

```bash
# Shutdown VM properly
shutdown -h now

# From host system
shasum < ft_linux.vdi > checksum.txt

# Or MD5
md5sum ft_linux.vdi > checksum.txt
```

## Troubleshooting

### Network Not Working
- Check VM network adapter is enabled
- Verify network service is running in guest
- Try different network mode (NAT/Bridged)

### Disk Space Issues
- Increase VM disk size
- Clean build directories
- Use dynamic disk allocation

### Boot Failures
- Verify GRUB installation
- Check partition mounting
- Review kernel configuration

## Resources

- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [LFS Book - Host System Requirements](http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html)
- [LFS Book - Partitioning](http://www.linuxfromscratch.org/lfs/view/stable/chapter02/creatingpartition.html)