# Known Issues and Solutions

## Overview

This document tracks common issues encountered during the ft_linux build and their solutions.

## Build Issues

### 1. Compilation Errors

#### Missing Dependencies
**Problem**: Package fails to compile due to missing libraries or headers.

**Solution**:
```bash
# Check if required packages are installed
# Install dependencies in correct order
# Refer to LFS book for dependency chains
```

#### GCC Version Mismatch
**Problem**: Package requires specific GCC version.

**Solution**:
```bash
# Build GCC pass1 and pass2 correctly
# Ensure proper toolchain in chapter 5
# Verify: gcc --version
```

### 2. Test Suite Failures

**Problem**: `make check` or `make test` reports failures.

**Analysis**:
- Some test failures are known and acceptable (documented in LFS)
- Critical: failures in glibc, gcc, binutils
- Non-critical: some tests in other packages

**Solution**:
```bash
# Review LFS book for known test failures
# Log test results: make check 2>&1 | tee test.log
# Only proceed if failures are documented as harmless
```

### 3. Out of Disk Space

**Problem**: Build fails due to insufficient disk space.

**Solution**:
```bash
# Clean build directories after installation
rm -rf /sources/package-build/

# Remove unnecessary files
# Increase VM disk size if needed
```

## Kernel Issues

### 1. Kernel Won't Boot

#### Missing Required Drivers
**Problem**: Kernel panic - cannot mount root filesystem.

**Solution**:
```bash
# Rebuild kernel with required drivers built-in (not modules):
# - SATA/IDE controller driver
# - EXT4 filesystem
# - Device needed for root filesystem
```

#### Wrong Root Device
**Problem**: Kernel cannot find root partition.

**Solution**:
```bash
# Check GRUB configuration
# Verify root= parameter points to correct device
# Example: root=/dev/sda2
```

### 2. Modules Not Loading

**Problem**: Kernel modules fail to load.

**Solution**:
```bash
# Verify udev/eudev is installed and running
# Check module dependencies: depmod -a
# Manually load: modprobe <module_name>
```

### 3. Custom Version Not Showing

**Problem**: `uname -r` doesn't show custom version string.

**Solution**:
```bash
# In kernel config: General setup -> Local version
# Set to: -<student_login>
# Rebuild kernel completely: make clean && make
```

## Bootloader Issues

### 1. GRUB Installation Fails

**Problem**: grub-install returns error.

**Solution**:
```bash
# Ensure /boot is mounted
mount | grep boot

# Install to MBR
grub-install /dev/sda

# If using chroot, bind mount /dev, /proc, /sys
mount --bind /dev $LFS/dev
mount -t proc proc $LFS/proc
mount -t sysfs sysfs $LFS/sys
```

### 2. GRUB Menu Doesn't Appear

**Problem**: System boots directly without GRUB menu.

**Solution**:
```bash
# Edit /boot/grub/grub.cfg
# Set timeout: set timeout=5
# Regenerate: grub-mkconfig -o /boot/grub/grub.cfg
```

### 3. Wrong Kernel Boots

**Problem**: Old kernel boots instead of custom kernel.

**Solution**:
```bash
# Verify kernel file name in /boot
ls -l /boot/vmlinuz-*

# Update grub.cfg to point to correct kernel
# Set default entry in grub.cfg
```

## Network Issues

### 1. No Network Connectivity

**Problem**: Cannot ping external hosts.

**Solution**:
```bash
# Check interface is up
ip link show

# Bring up interface
ip link set eth0 up

# Configure IP (if not using DHCP)
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1

# Or start DHCP client
dhclient eth0
```

### 2. DNS Not Working

**Problem**: Can ping IPs but not domain names.

**Solution**:
```bash
# Create /etc/resolv.conf
cat > /etc/resolv.conf << "EOF"
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
```

### 3. Network Service Won't Start

**Problem**: Network service fails at boot.

**Solution**:
```bash
# Check service scripts in /etc/init.d/
# Verify network configuration in /etc/sysconfig/
# Check permissions: chmod +x /etc/init.d/network
```

## System Boot Issues

### 1. Kernel Panic

**Problem**: System crashes during boot with kernel panic.

**Common Causes & Solutions**:
```bash
# 1. Cannot mount root
#    - Check fstab
#    - Verify filesystem driver in kernel

# 2. Init not found
#    - Check /sbin/init exists
#    - Verify init= parameter in grub

# 3. Missing libraries
#    - Rebuild or reinstall glibc
#    - Check /lib and /lib64 symlinks
```

### 2. Services Fail to Start

**Problem**: System boots but services don't start.

**Solution**:
```bash
# Check service scripts
ls -l /etc/init.d/

# Verify run levels
ls -l /etc/rc*.d/

# Manual service start for debugging
/etc/init.d/service_name start
```

### 3. Login Issues

**Problem**: Cannot login to system.

**Solution**:
```bash
# Reset root password (from rescue mode)
passwd root

# Verify shadow and passwd files
pwck
grpck

# Check PAM configuration if installed
ls -l /etc/pam.d/
```

## Package-Specific Issues

### 1. Glibc Build Failures

**Problem**: Glibc fails to compile.

**Solution**:
- Ensure host system meets LFS requirements
- Build in separate directory
- Follow LFS instructions exactly
- This is critical - must succeed

### 2. GCC Bootstrap Issues

**Problem**: GCC pass1 or pass2 fails.

**Solution**:
```bash
# Clean and restart
# Verify binutils is installed correctly
# Check for proper directory structure
# Ensure $LFS is set correctly
```

### 3. GRUB Configuration Issues

**Problem**: GRUB won't configure or install.

**Solution**:
```bash
# Ensure EFI or BIOS modules are available
# For BIOS: grub-install --target=i386-pc /dev/sda
# Check /boot/grub directory exists
```

## Debugging Techniques

### 1. Enable Verbose Boot

```bash
# Remove 'quiet' from kernel parameters in grub.cfg
# Add: debug loglevel=7
```

### 2. Check Logs

```bash
# System logs
cat /var/log/messages
cat /var/log/syslog

# Kernel messages
dmesg | less

# Boot messages
journalctl -b (if using systemd)
```

### 3. Single User Mode

```bash
# Boot to single user mode
# In GRUB, append to kernel line: single
# Or: init=/bin/bash
```

## Performance Issues

### 1. Slow Compilation

**Problem**: Package compilation takes too long.

**Solution**:
```bash
# Use parallel make
make -j$(nproc)

# But be careful with memory usage
# Reduce if out of memory: make -j2
```

### 2. VM Performance

**Problem**: Virtual machine runs slowly.

**Solution**:
- Increase VM RAM allocation
- Allocate more CPU cores
- Enable hardware virtualization (VT-x/AMD-V)
- Use fixed-size disk instead of dynamic

## Validation

### Check System Integrity

```bash
# Verify key binaries
which bash gcc make

# Check libraries
ldconfig -p

# Verify kernel
uname -a

# Test network
ping -c 3 google.com

# Check services
ps aux | grep -E 'udev|syslog|init'
```

## Resources

- [LFS FAQ](http://www.linuxfromscratch.org/lfs/faq.html)
- [LFS Hints](http://www.linuxfromscratch.org/hints/)
- [LFS Mailing Lists](http://www.linuxfromscratch.org/mail.html)

## Getting Help

1. Check LFS book errata
2. Search LFS mailing list archives
3. Review build logs carefully
4. Ask specific questions with error messages
5. Provide system details and steps taken