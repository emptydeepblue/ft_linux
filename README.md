# ft_linux

Build a minimal but functional Linux distribution from source — kernel, toolchain, init system, and userspace — following the Linux From Scratch (LFS) methodology.

**Specialization:** Unix/Kernel
**XP:** 4,200 · **People:** 1 · **Status:** 🟨 In progress (scripts written, full build not yet run)

> 📖 **New here?** Read [docs/concepts.md](docs/concepts.md) — a full
> walkthrough of the project and every concept behind it (toolchain bootstrapping,
> chroot, the boot chain, FHS, init, eudev, GRUB…). This README is the quick-start.

---

## 🚀 Features

- Custom-compiled Linux kernel (≥ 4.0), booted on a VM
- Multi-stage toolchain bootstrap (cross-toolchain → temporary tools → chroot → final system)
- FHS-compliant root filesystem
- GRUB bootloader, SysVinit init, eudev device manager
- Network connectivity, package management primitives, working shell environment
- Reproducible build: every step scripted in `build/`

## Two separate worlds

| | Where | Needs | Folder |
|---|---|---|---|
| **Build** the disk image | a Linux host with sudo (here: WSL2, Ubuntu 22.04) | hours of compiling | [`build/`](build/), [`config/`](config/) |
| **Evaluate** it | a school PC (Ubuntu 22.04 + VirtualBox) | no sudo, no compiling | [`eval/`](eval/README.md) |

## 🛠️ Build

**Prerequisites:** an Ubuntu 22.04 host with sudo (see
[docs/phases/1_host.md](docs/phases/1_host.md)),
x86_64, ≥ 4 cores, ≥ 8 GB RAM, ≥ 40 GB free disk.

```bash
# Each folder of build/ is one phase; its header says WHO runs it and WHERE.
# Phases with a run.sh are resumable:  run.sh --list | run.sh FROM [TO]
# (FROM/TO = LFS book section, e.g. "8.29" = GCC, "5 5" = only chapter 5).
# Logs: $LFS/sources/logs/<phase>/<step>.log

# 1_host — root on the host, one script at a time (LFS ch. 2–4)
sudo bash build/1_host/01_host_prepare.sh       # apt deps, sh->bash, runs 02_version_check
sudo bash build/1_host/03_disk_partition.sh     # raw image (default) or: … /dev/sdX
sudo bash build/1_host/04_download_sources.sh   # into $LFS/sources, md5 checked
sudo bash build/1_host/05_lfs_user.sh           # lfs user + env + copy of scripts
sudo bash build/lfs_disk.sh mount               # only after a WSL/host restart

# 2_toolchain — user lfs on the host (ch. 5 cross-toolchain, ch. 6 temporary tools)
sudo su - lfs
bash $FT_DIR/build/2_toolchain/run.sh
exit

# 3_chroot — root on the host (ch. 7.2–7.4)
sudo bash build/3_chroot/01_chown_root.sh       # once
sudo bash build/3_chroot/02_enter_chroot.sh     # every time you (re)enter

# 4..7 — root inside the chroot
bash $FT_DIR/build/4_chroot_tools/run.sh        # ch. 7.5–7.13
bash $FT_DIR/build/5_final_system/run.sh        # ch. 8, unattended (hours)
bash $FT_DIR/build/6_boot/run.sh                # ch. 9–10: bootscripts, /etc, kernel, GRUB, root password
bash $FT_DIR/build/7_network/run.sh             # BLFS: CA certificates, wget, dhcpcd, ssh

# 8_release — on the host, chroot exited: test, shrink, .vdi + checksum
sudo bash build/lfs_disk.sh detach
bash build/8_release/01_boot_test.sh            # QEMU, no sudo, image untouched
sudo bash build/lfs_disk.sh mount && sudo bash build/8_release/02_prepare_image.sh
sudo bash build/lfs_disk.sh detach && sudo bash build/8_release/03_make_vdi.sh
```

What every phase does and why: [docs/](docs/README.md), one page per folder of `build/`.

## 🧪 Evaluation

The disk image is not in git: `ft_linux.vdi.xz` is attached to the GitHub
Release, and its SHA-1 (`shasum < ft_linux.vdi`, uncompressed) is in
[checksum.txt](checksum.txt). The full procedure — verify the checksum, create
the VM (no sudo), ssh in, show the requirements — is in
**[eval/README.md](eval/README.md)**.

## 📁 Project Structure

```
ft_linux/
├── README.md           # this file — quick-start + project card
├── checksum.txt        # SHA of the final disk image (for peer evaluation)
├── config/             # ft_linux.conf (login, versions, paths, disk), kernel.config (kconfig fragment),
│                       #   extra-sources.list (eudev, check, BLFS network tarballs + md5)
├── eval/               # EVALUATION (school PC, no sudo): verify checksum, create the VM, ft_check
├── build/              # BUILD (host with sudo): one folder per phase, run in numeric order
│   ├── lib/            # common.sh (config + who/where guards), disk.sh, steps.sh (step runner + logs)
│   ├── lfs_disk.sh     # mount | umount | detach | status of the LFS disk/image
│   ├── sync_to_lfs.sh  # copies build/ + config/ to $LFS/sources/ft_linux (lfs user + chroot)
│   ├── 1_host/         # [root, host]   host prep, version check, disk, sources, lfs user (ch. 2–4)
│   ├── 2_toolchain/    # [lfs, host]    run.sh: 5.xx cross-toolchain, 6.xx temporary tools
│   ├── 3_chroot/       # [root, host]   01 chown to root (once), 02 mount + enter chroot (ch. 7.2–7.4)
│   ├── 4_chroot_tools/ # [root, chroot] run.sh: 7.05–7.13 dirs, files, extra temporary tools
│   ├── 5_final_system/ # [root, chroot] run.sh: 8.03–8.82, file name = book section
│   ├── 6_boot/         # [root, chroot] run.sh: bootscripts, /etc, kernel, GRUB (ch. 9–10)
│   ├── 7_network/      # [root, chroot] run.sh: libtasn1, p11-kit, make-ca, wget, dhcpcd, openssh (BLFS)
│   └── 8_release/      # [host]         QEMU boot test, shrink, .vdi + checksum.txt + .vdi.xz
└── docs/               # concepts, one page per build phase, packages, cheatsheet, issues
```

## 🔧 Implementation

**System specs:**
- **Base:** Linux From Scratch 12.4 (SysV)
- **Hostname:** everonel
- **Architecture:** x86_64
- **Kernel:** Linux 6.16.1-everonel (subject requires ≥ 4.0)
- **Toolchain:** GCC 15.2.0 · Glibc 2.42
- **Init:** SysVinit
- **Bootloader:** GRUB 2 (BIOS/MBR)
- **Device manager:** eudev

**Partition layout** (the build disk is `/dev/sdb` on the host; the same disk is
`/dev/sda` once booted inside the VM):

| Mount  | Device     | FS   | Purpose         |
|--------|------------|------|-----------------|
| `/boot`| /dev/sda1  | ext4 | Kernel + GRUB   |
| `/`    | /dev/sda2  | ext4 | Root filesystem |
| swap   | /dev/sda3  | swap | Swap            |

**Build pipeline:**
1. **Compiler toolchain** — host-built cross-binutils + GCC pass 1 targeting the LFS root
2. **Temporary tools** — minimal userspace built with the cross-toolchain
3. **Chroot** — switch into the LFS root, rebuild final tools using themselves
4. **Final system** — full userspace, kernel build, GRUB install

## 📚 Learning Objectives

- How a Linux system actually boots (BIOS/UEFI → bootloader → kernel → init → userspace)
- Cross-compilation and toolchain bootstrapping
- FHS, package layout, and the role of each base package
- Kernel configuration and build (`make menuconfig`, modules, initramfs)
- VM disk images, partitioning, GRUB

## 🔗 References

- [Documentation](docs/README.md) — concepts, phases, packages
- [Linux From Scratch (LFS)](https://www.linuxfromscratch.org/lfs/view/stable/index.html)
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml)
- [Software-Building HOWTO](https://tldp.org/HOWTO/Software-Building-HOWTO.html)
- [kernel.org](https://www.kernel.org/)
- [docs/cheatsheet.md](docs/cheatsheet.md), [docs/issues.md](docs/issues.md)

---

*42 School — RNCP7 · Unix/Kernel*
