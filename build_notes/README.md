# Build Notes for ft_linux

This document serves as a comprehensive guide for setting up the build environment and compiling the Linux From Scratch (LFS) system for the ft_linux subject. It includes step-by-step instructions, troubleshooting tips, and known issues encountered during the build process.

*Table of Contents:*
- [01 VM Setup](01_vm_setup.md)
- [02 Disk Partitioning and Formatting](02_disk_partitioning.md)
- [03 User and Environment Setup](03_user_env_setup.md)
- [04 Downloading LFS Sources](04_download_sources.md)
- [05 Building Cross-Toolchain](05_cross_toolchain.md)
- [06 Building Cross Temporary Tools](06_temp_tools.md)
- [07 Chroot setup](07_chroot_setup.md)
- [08 Building LFS System](08_building_lfs.md) 
- [09 Configuring the System](09_configuring_system.md)
- [10 Compile Kernel and GRUB](10_kernel_and_grub.md)
- [11 Post Boot Configuration](11_post_boot.md)

You can follow the step by step guides or just execute the scripts for each step:

**1. VM Setup**
follow the guide [vm setup](steps/01_vm_setup.md)
**2. As root on host — partition the LFS disk**
```bash
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdb
```
**3. As root on host — create user + dirs + shell env**
```bash
sudo bash scripts/01_setup/02_env_setup.sh
```
**4. Switch to lfs, download all sources**
```bash
sudo su - lfs
bash scripts/01_setup/03_download_sources.shs
```
**5. Verify env and tools**
```bash
bash scripts/01_setup/04_version_check.sh
bash scripts/02_build/01_check_env.shs
```
**6. Build the entire cross-toolchain (or resume from step N)**
```bash
bash scripts/02_build/02_run_toolchain.sh
# bash scripts/02_build/02_run_toolchain.sh 3   ← resume from step 3
```

*Other Resources:*
- [Build Logs](logs/)
- [Known Issues and Solutions](issues.md)
- [Package Sources and Checksums](sources.md)