# ft_linux

Build a minimal but functional Linux distribution from source — kernel, toolchain, init system, and userspace — following the Linux From Scratch (LFS) methodology.

**Specialization:** Unix/Kernel
**XP:** 4,200 · **People:** 1 · **Status:** 🟦 Completed

> 📖 **New here?** Read [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md) — a full
> walkthrough of the project and every concept behind it (toolchain bootstrapping,
> chroot, the boot chain, FHS, init, eudev, GRUB…). This README is the quick-start.

---

## 🚀 Features

- Custom-compiled Linux kernel (≥ 4.0), booted on a VM
- Multi-stage toolchain bootstrap (cross-toolchain → temporary tools → chroot → final system)
- FHS-compliant root filesystem
- GRUB bootloader, SysVinit init, eudev device manager
- Network connectivity, package management primitives, working shell environment
- Reproducible build: every step scripted in `scripts/`

## 🛠️ Build & Run

**Prerequisites:**
- VirtualBox / VMware
- x86_64 host CPU, ≥ 4 cores recommended
- ≥ 8 GB RAM, ≥ 30 GB disk for the LFS build environment
- Host satisfies LFS `version-check.sh`

```bash
# 1. Host prep (as root), then download sources (as the lfs user)
sudo bash scripts/01_setup/host_prepare.sh       # apt deps, sh->bash, version check
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdb
sudo bash scripts/01_setup/02_env_setup.sh
sudo su - lfs
bash $FT_DIR/scripts/01_setup/03_download_sources.sh

# 2. Toolchain + temporary tools (as lfs; resume from step N with: … <N>)
bash $FT_DIR/scripts/02_build/01_run_compiler_toolchain.sh
bash $FT_DIR/scripts/02_build/02_run_temporary_tools.sh

# 3. Enter chroot (root on host), then build the rest inside it
sudo bash scripts/02_build/03_enter_chroot.sh
bash /sources/ft_linux/scripts/02_build/04_run_chroot_tools.sh      # inside chroot
bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh      # inside chroot
```

Then configure the system, build the kernel, and install GRUB — see
[notes/steps/build/10_system_config.md](notes/steps/build/10_system_config.md)
and [11_kernel_bootloader.md](notes/steps/build/11_kernel_bootloader.md).

## 🧪 Evaluation

The disk image's SHA checksum is in [checksum.txt](checksum.txt). Generated with:

```bash
shasum < disk.vdi > checksum.txt
```

The `.vdi` itself is shared out-of-band for peer evaluation.

## 📁 Project Structure

```
ft_linux/
├── README.md           # this file — quick-start + project card
├── checksum.txt        # SHA of the final disk image (for peer evaluation)
├── wget-list-sysv      # pinned list of every upstream source URL
├── config/             # ft_linux.conf (login, versions, paths, disk) + fstab, grub.cfg, kernel.config
├── scripts/
│   ├── lib/common.sh   # loads config/ft_linux.conf (sourced by the scripts)
│   ├── sync_to_lfs.sh  # copies scripts/ + config/ to $LFS/sources/ft_linux (lfs user + chroot)
│   ├── 01_setup/       # host prep + version check, partitioning, env, source download
│   └── 02_build/       # toolchain → temporary tools → chroot → final system
│       ├── compiler-toolchain/   temporary-tools/
│       ├── chroot-tools/         final-system/
│       └── 0{1..5}_run_*.sh      # per-phase orchestrators
├── notes/              # step-by-step guides, cheatsheet, known issues
│   ├── steps/setup/    notes/steps/build/
│   ├── cheatsheet.md   issues.md   sources/sources.md
└── docs/
    └── DOCUMENTATION.md  # full conceptual walkthrough
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

- [Full project documentation](docs/DOCUMENTATION.md) — concepts explained end to end
- [Linux From Scratch (LFS)](https://www.linuxfromscratch.org/)
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml)
- [Software-Building HOWTO](https://tldp.org/HOWTO/Software-Building-HOWTO.html)
- [kernel.org](https://www.kernel.org/)
- [notes/cheatsheet.md](notes/cheatsheet.md), [notes/issues.md](notes/issues.md)

---

*42 School — RNCP7 · Unix/Kernel*
