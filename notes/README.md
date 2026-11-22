# Build Notes — ft_linux

These notes are the narrated walkthrough behind the scripts in
[`../scripts/`](../scripts/): step-by-step instructions, the reasoning for each
phase, and the problems hit along the way. For the high-level concepts, read
[`../docs/DOCUMENTATION.md`](../docs/DOCUMENTATION.md) first; for a quick
quoting-during-evaluation reference, see [`cheatsheet.md`](cheatsheet.md).

## Walkthrough

**Setup (host side)**
- [01 — VM setup](steps/setup/01_vm_setup.md)
- [02 — Disk partitioning & formatting](steps/setup/02_disk_partitioning.md)
- [03 — User & environment setup](steps/setup/03_user_env_setup.md)
- [04 — Downloading the LFS sources](steps/setup/04_download_sources.md)

**Build**
- [06 — Cross-toolchain](steps/build/06_cross_toolchain.md)
- [07 — Cross-compiled temporary tools](steps/build/07_temporary_tools.md)
- [08 — Chroot setup & extra temporary tools](steps/build/08_chroot_setup.md)
- [09 — Final system (Chapter 8 packages)](steps/build/09_final_system.md)
- [10 — System configuration](steps/build/10_system_config.md)
- [11 — Kernel build & bootloader](steps/build/11_kernel_bootloader.md)

## TL;DR — run the scripts

Each phase has a guide above; if you just want to run it, the scripts mirror the
same order. All build commands assume you are the right user with the
environment sourced (see each guide for who runs what).

```bash
# 1. Host prep (as root), then download sources (as the lfs user)
sudo bash scripts/01_setup/host_prepare.sh       # apt deps, sh->bash, version check
sudo bash scripts/01_setup/01_disk_partition.sh   # image (default) or: … /dev/sdX
sudo bash scripts/lfs_disk.sh mount               # after every WSL/host restart
sudo bash scripts/01_setup/02_env_setup.sh
sudo su - lfs
bash $FT_DIR/scripts/01_setup/03_download_sources.sh

# 2. Toolchain + temporary tools (as lfs; resume from step N with: … <N>)
bash $FT_DIR/scripts/02_build/01_run_compiler_toolchain.sh
bash $FT_DIR/scripts/02_build/02_run_temporary_tools.sh

# 3. Enter chroot (root on host), then build inside it
sudo bash scripts/02_build/03_enter_chroot.sh
bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh      # inside chroot
bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh      # inside chroot
```

Then follow guides [10](steps/build/10_system_config.md) and
[11](steps/build/11_kernel_bootloader.md) to configure the system, build the
kernel, and install GRUB.

## Other resources

- [Known issues & solutions](issues.md)
- [Package list & sources](sources/sources.md)
- [Evaluation cheatsheet](cheatsheet.md)
