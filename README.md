# ft_linux

## How to Train Your Kernel - Custom Linux Distribution

This repository contains the configuration files and build notes for a custom Linux distribution built as part of the 42 ft_linux project.

## Project Overview

A minimal but functional Linux distribution built from scratch, including:
- Custom compiled Linux kernel (version >= 4.0)
- Essential system packages and utilities
- Network connectivity
- FHS-compliant filesystem hierarchy

## System Specifications

- **Kernel Version**: Linux 4.x-everonel
- **Hostname**: everonel
- **Architecture**: 64-bit (or 32-bit as chosen)
- **Init System**: SysVinit (or SystemD)
- **Bootloader**: GRUB
- **Device Manager**: Eudev

## Partition Scheme

The system uses at least 3 partitions:
- `/boot` - Boot partition (mounted as /dev/sda1)
- `/` - Root partition (mounted as /dev/sda2)
- `swap` - Swap partition (/dev/sda3)

## Directory Structure

```
ft_linux/
├── checksum.txt          # SHA checksum of disk image
├── README.md            # This file
├── subject.md           # Project subject
├── build_notes/         # Build documentation
│   ├── issues.md       # Known issues and solutions
│   ├── kernel.md       # Kernel build process
│   ├── packages.md     # Package installation notes
│   └── vm_config.md    # Virtual machine configuration
└── config/             # System configuration files
    ├── fstab           # Filesystem table
    ├── grub.cfg        # GRUB configuration
    └── kernel.config   # Kernel configuration
```

## Build Process

### Prerequisites
- VirtualBox or VMWare
- Linux host system or build environment
- Internet connection for downloading sources

### Steps

1. **VM Setup** - See [build_notes/vm_config.md](build_notes/vm_config.md)
2. **Kernel Build** - See [build_notes/kernel.md](build_notes/kernel.md)
3. **Package Installation** - See [build_notes/packages.md](build_notes/packages.md)
4. **Configuration** - Apply configs from `config/` directory

## Required Packages

The system includes all mandatory packages specified in the subject:
- Core utilities (coreutils, bash, etc.)
- Build tools (gcc, make, autotools, etc.)
- System tools (udev, sysvinit, grub, etc.)
- Libraries (glibc, ncurses, readline, etc.)

See [build_notes/packages.md](build_notes/packages.md) for the complete list and installation order.

## Network Configuration

The system is configured with network connectivity for:
- Package downloads (wget/curl)
- System updates
- Remote access (SSH if configured)

## Evaluation

For peer evaluation:
1. The disk image checksum is stored in [checksum.txt](checksum.txt)
2. The virtual machine disk image is available separately
3. Generated with: `shasum < disk.vdi > checksum.txt`

## Troubleshooting

Common issues and solutions are documented in [build_notes/issues.md](build_notes/issues.md).

## Resources

- [Linux From Scratch (LFS)](http://www.linuxfromscratch.org/)
- [Kernel.org](https://www.kernel.org/)
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml)

## Author

Student: everonel 
School: 42  
Project: ft_linux (how_to_train_your_kernel)