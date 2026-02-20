# Kernel Build Process

## Overview

This document describes the process for building a custom Linux kernel for ft_linux.

## Requirements

- Kernel version >= 4.0 (stable or unstable)
- Kernel sources in `/usr/src/kernel-$(version)`
- Custom version string with student login
- Kernel binary named: `vmlinuz-<linux_version>-<student_login>`

## Kernel Version Selection

Choose a kernel version >= 4.0. Recommended versions:
- 4.19.x (LTS)
- 5.4.x (LTS)
- 5.10.x (LTS)
- 5.15.x (LTS)

## Download Kernel Sources

```bash
cd /usr/src
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.x.tar.xz
tar -xvf linux-4.19.x.tar.xz
ln -s linux-4.19.x kernel-4.19.x
cd kernel-4.19.x
```

## Configure the Kernel

### Option 1: Use Existing Config
```bash
# Copy the provided config
cp /path/to/config/kernel.config .config
make oldconfig
```

### Option 2: Interactive Configuration
```bash
# Start with defaults
make defconfig

# Customize with menu
make menuconfig
```

### Key Configuration Options

1. **Set Custom Version String**
   - General setup → Local version
   - Set to: `-<student_login>`

2. **Essential Options**
   - Enable loadable module support
   - Enable block layer
   - Networking support
   - Device drivers (especially for VM)
   - File systems (ext4, proc, sysfs, tmpfs)

3. **VM-Specific Drivers**
   - VirtualBox: Enable VBOX drivers
   - VMWare: Enable VMWARE drivers

## Build the Kernel

```bash
# Compile the kernel
make -j$(nproc)

# Compile modules
make modules

# Install modules
make modules_install

# Install kernel
make install
```

## Manual Installation (if make install doesn't work)

```bash
# Copy kernel image
cp arch/x86/boot/bzImage /boot/vmlinuz-4.19.x-<student_login>

# Copy System.map
cp System.map /boot/System.map-4.19.x-<student_login>

# Copy config
cp .config /boot/config-4.19.x-<student_login>

# Create initramfs (if needed)
mkinitramfs -o /boot/initrd.img-4.19.x-<student_login> 4.19.x-<student_login>
```

## Update Bootloader

After kernel installation, update GRUB:

```bash
# Update GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Or manually edit /boot/grub/grub.cfg
# See config/grub.cfg for reference
```

## Verify Installation

```bash
# Check kernel files
ls -lh /boot/vmlinuz-*

# Check modules
ls /lib/modules/

# Reboot and verify
uname -r
# Should show: 4.19.x-<student_login>
```

## Kernel Configuration Notes

### Required Features

- Loadable kernel module support (for udev)
- EXT4 filesystem support
- Networking (TCP/IP)
- Device drivers for virtual hardware
- Pseudo filesystems (proc, sysfs, devpts, tmpfs)

### Recommended Features

- Swap support
- GRUB support
- ACPI support
- PCI support

## Troubleshooting

### Build Errors

1. **Missing dependencies**
   ```bash
   # Install build essentials
   # bc, bison, flex, libssl-dev, libelf-dev
   ```

2. **Out of memory during build**
   ```bash
   # Reduce parallelism
   make -j2
   ```

### Boot Issues

1. **Kernel panic**
   - Check required drivers are built-in (not modules)
   - Verify initramfs if using modules for boot devices

2. **Cannot find root filesystem**
   - Check GRUB configuration (root= parameter)
   - Verify filesystem driver is enabled

## Additional Resources

- [kernel.org documentation](https://www.kernel.org/doc/)
- [Linux Kernel in a Nutshell](http://www.kroah.com/lkn/)
- [LFS Kernel Configuration](http://www.linuxfromscratch.org/lfs/view/stable/chapter08/kernel.html)