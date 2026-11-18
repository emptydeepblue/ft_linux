# ft_linux — Full Documentation

> Build a complete, bootable Linux distribution from nothing but source code —
> compiler, C library, kernel, init system and userland — following the
> [Linux From Scratch](https://www.linuxfromscratch.org/) (LFS 12.4) methodology.
>
> **42 School · RNCP7 · Unix/Kernel** — Status: ✅ Completed

This document is the conceptual companion to the [README](../README.md). The
README tells you *how to run the scripts*; this file explains *what each piece
is, why it exists, and how the whole thing fits together*. Read it once and the
build stops being magic.

---

## Table of contents

1. [What this project actually is](#1-what-this-project-actually-is)
2. [The big picture: how a Linux system is born](#2-the-big-picture-how-a-linux-system-is-born)
3. [Why you can't just "compile Linux"](#3-why-you-cant-just-compile-linux--the-bootstrapping-problem)
4. [The toolchain — the heart of the build](#4-the-toolchain--the-heart-of-the-build)
5. [The five build stages](#5-the-five-build-stages)
6. [How the finished system boots](#6-how-the-finished-system-boots)
7. [Anatomy of the filesystem (FHS)](#7-anatomy-of-the-filesystem-fhs)
8. [Key subsystems explained](#8-key-subsystems-explained)
9. [Repository layout](#9-repository-layout)
10. [Running the build yourself](#10-running-the-build-yourself)
11. [Glossary](#11-glossary)
12. [References](#12-references)

---

## 1. What this project actually is

Most people install Linux from an ISO. Behind that ISO, somebody compiled a few
hundred packages, configured a kernel, set up a bootloader and packed it all
into a disk image. **ft_linux does that by hand.**

The result is a minimal but genuinely complete distribution that:

- boots on a real (virtual) machine through GRUB,
- runs a custom-compiled Linux kernel whose version string carries my login,
- brings up userspace with the classic **SysVinit** init system,
- manages devices dynamically with **eudev**,
- gets on the network over DHCP,
- and gives you a working Bash shell with the standard GNU userland.

Nothing here is downloaded as a binary package. Every single executable on the
final disk — including the compiler that built it — was compiled from upstream
source tarballs during the build.

### The system that comes out

| Item | Value |
|---|---|
| Distribution base | Linux From Scratch **12.4** (SysV) |
| Hostname | `everonel` (my 42 login) |
| Architecture | `x86_64` |
| Kernel | `6.16.1-everonel` (≥ 4.0 required by the subject) |
| C library | Glibc **2.42** |
| Compiler | GCC **15.2.0** |
| Init system | **SysVinit** (`/sbin/init`) |
| Device manager | **eudev** |
| Bootloader | **GRUB 2** (BIOS/MBR) |
| Kernel sources | `/usr/src/kernel-6.16.1` |
| Kernel binary | `/boot/vmlinuz-6.16.1-everonel` |

---

## 2. The big picture: how a Linux system is born

A running Linux box is really five layers stacked on top of each other. This
project builds them bottom-up:

```
        ┌─────────────────────────────────────────────┐
   (5)  │  Userland: bash, coreutils, GRUB, eudev …    │   ← what you type at
        ├─────────────────────────────────────────────┤
   (4)  │  Init system (SysVinit) — PID 1              │   ← first process
        ├─────────────────────────────────────────────┤
   (3)  │  Linux kernel (6.16.1-everonel)              │   ← talks to hardware
        ├─────────────────────────────────────────────┤
   (2)  │  C library (glibc) — syscalls wrapper        │   ← every program needs it
        ├─────────────────────────────────────────────┤
   (1)  │  Toolchain (binutils + gcc) — the compiler   │   ← builds everything above
        └─────────────────────────────────────────────┘
                         on top of
        ┌─────────────────────────────────────────────┐
        │  Hardware / VM (CPU, disk, RAM, NIC)         │
        └─────────────────────────────────────────────┘
```

The trick is that layer (1) has to exist *before* you can build anything, but
you can't trust the **host's** compiler to build a clean system. That tension is
the whole reason LFS is structured the way it is — see the next section.

---

## 3. Why you can't just "compile Linux" — the bootstrapping problem

You want a self-contained system whose programs link only against **its own**
libraries. But to compile those programs you need a compiler, and the only
compiler you have at the start belongs to the **host** distribution (Ubuntu, in
this build). If you naively compile with the host compiler, the resulting
binaries get silently wired to the host's glibc, host headers and host paths.
Reboot into your new system without those host files present and everything
crashes.

This is the classic **bootstrapping problem**: *you need the system to build the
system.*

LFS solves it with a deliberate, multi-pass dance:

1. Use the host compiler **once** to build a brand-new **cross-compiler** that
   targets an imaginary machine (`x86_64-lfs-linux-gnu`). Because the target
   triplet differs from the host triplet, the build system is *forced* to keep
   host and target artifacts separate — no accidental contamination.
2. With that cross-compiler, build a minimal set of **temporary tools** into the
   LFS partition. These still depend a little on the host kernel, but not on the
   host's files.
3. `chroot` into the LFS partition so the host filesystem disappears entirely.
4. Rebuild everything **natively**, this time using only the tools we just
   placed inside LFS. The final compiler compiles itself, proving the system can
   reproduce itself with zero host involvement.

By the end, the only thing borrowed from the host is the running **kernel**
(used during chroot), and that gets replaced the moment you reboot into your own
kernel.

---

## 4. The toolchain — the heart of the build

A **toolchain** is the set of programs that turn source code into runnable
binaries. In the GNU world it is three packages:

| Package | Role |
|---|---|
| **Binutils** | The assembler (`as`) and linker (`ld`) — turn assembly into object files and stitch object files + libraries into an executable. |
| **GCC** | The C/C++ compiler — turns `.c` into assembly. |
| **Glibc** | The GNU C Library — the runtime every C program calls into (`printf`, `malloc`, `open`…). It wraps raw kernel **syscalls** in a portable API. |

### Target triplets

A "triplet" like `x86_64-pc-linux-gnu` describes *who a binary is for*:
`<architecture>-<vendor>-<kernel>-<abi>`. The build uses two:

- **host triplet** — your Ubuntu machine.
- **`$LFS_TGT` = `x86_64-lfs-linux-gnu`** — the LFS target. The fake `lfs`
  vendor field is the lever that keeps the cross-build honest: tools built for
  this triplet refuse to quietly use host components.

### Cross-compiler vs. native compiler

- A **native compiler** runs on machine A and produces binaries for machine A.
- A **cross-compiler** runs on machine A and produces binaries for machine B.

We build a cross-compiler even though host and target are *both* x86_64, purely
to enforce isolation. Once we're safely inside the chroot, we throw the
cross-compiler away and build an ordinary native compiler.

### Why glibc is built so early (and so often)

Almost every program links against glibc, so it has to exist before its
dependents. It also defines the **ABI** (the binary contract for how functions
pass arguments, how structs are laid out, etc.). Build glibc against the wrong
kernel headers and binaries make malformed syscalls. That's why the very first
toolchain steps install the **Linux API headers** (`make headers`) — they tell
glibc exactly which syscalls the kernel offers.

---

## 5. The five build stages

The build is driven by five top-level scripts in [`scripts/02_build/`](../scripts/02_build/),
each orchestrating a directory of per-package scripts. Run them in order; each
accepts an optional step number to **resume after a failure**
(e.g. `… 05_run_final_system.sh 25`).

### Stage 0 — Host prep & sources ([`scripts/01_setup/`](../scripts/01_setup/))

Before any compiling:

- **`00_version_check.sh`** — confirms the host has new-enough versions of GCC,
  make, bash, etc. (LFS won't build on ancient toolchains).
- **`01_disk_partition.sh`** — partitions the target disk (see
  [partition layout](#partition-layout)).
- **`02_env_setup.sh`** — creates an unprivileged **`lfs`** user with a
  pristine, minimal environment (clean `PATH`, `LFS=/mnt/lfs`,
  `LFS_TGT`, `MAKEFLAGS` for parallel builds). Building as a locked-down user
  prevents a stray `make install` from scribbling over the host system.
- **`03_download_sources.sh`** — fetches every source tarball listed in
  [`wget-list-sysv`](../wget-list-sysv) and verifies them against
  [`checksum.txt`](../checksum.txt) / `md5sums`.

### Stage 1 — Compiler toolchain ([`compiler-toolchain/`](../scripts/02_build/compiler-toolchain/))

Built **on the host, as the `lfs` user**, into `$LFS/tools`:

1. `binutils` (pass 1) — the cross linker/assembler.
2. `gcc` (pass 1) — a minimal cross-compiler, just enough to build glibc.
3. Linux **API headers** — the kernel's syscall/ioctl interface for glibc.
4. `glibc` — the target C library.
5. `libstdc++` — the C++ standard library (split out of GCC because it needs a
   working glibc first).

At the end of this stage you own a cross-compiler that can build target binaries.

### Stage 2 — Temporary tools ([`temporary-tools/`](../scripts/02_build/temporary-tools/))

17 packages (`m4`, `ncurses`, `bash`, `coreutils`, `sed`, `tar`, a second pass
of `binutils`/`gcc`, …) cross-compiled with `--host=$LFS_TGT` and installed
**directly into `$LFS`**. This is the minimum userland required to survive
inside a chroot without the host: a shell, file utilities, a build system, and a
compiler that now runs *on the target*.

### Stage 3 — Enter chroot ([`03_enter_chroot.sh`](../scripts/02_build/03_enter_chroot.sh) + [`chroot-tools/`](../scripts/02_build/chroot-tools/))

Two phases with **different users**:

1. **On the host as root:** give `root` ownership of `$LFS`, then mount the
   **virtual kernel filesystems** (`/dev`, `/proc`, `/sys`, `/run`) into `$LFS`
   so processes inside the chroot can still talk to the kernel. Then `chroot`
   into `$LFS` with a scrubbed environment.
2. **Inside the chroot as root:** create the full directory tree, essential
   files (`/etc/passwd`, `/etc/hosts`, …), and build a handful more temporary
   packages (`gettext`, `bison`, `perl`, `texinfo`, `util-linux`) that the final
   build needs. A cleanup step strips debug symbols and removes documentation to
   reclaim space.

From here on the host filesystem is **invisible**. Everything is native.

### Stage 4 — Final system ([`final-system/`](../scripts/02_build/final-system/))

The big one: ~78 packages compiled **natively, in strict dependency order**,
each installing into `/usr`. Highlights:

- **glibc** is rebuilt as the real, final C library.
- **GCC** is rebuilt natively — the longest single step (30–90 min) — and its
  test suite confirms the toolchain is sound.
- Core userland: `coreutils`, `bash`, `findutils`, `grep`, `sed`, `gawk`,
  `tar`, `gzip`, `xz`, `util-linux`, `e2fsprogs` (ext4 tools), …
- System pieces: `shadow` (passwords — prompts for the root password),
  `eudev` (device manager), `sysvinit` (init), `sysklogd` (logging),
  `iproute2` (networking), `grub` (bootloader), `kmod` (module loading).

> **Build-order deviation worth knowing:** modern glibc needs Python 3 at build
> time, so this build bootstraps a throwaway `libffi` + `python` *before* glibc,
> then rebuilds both at their normal positions later. See
> [`notes/steps/build/09_final_system.md`](../notes/steps/build/09_final_system.md).

### Stage 5 — Configuration, kernel & bootloader

Documented in [`notes/steps/build/10_system_config.md`](../notes/steps/build/10_system_config.md)
and [`11_kernel_bootloader.md`](../notes/steps/build/11_kernel_bootloader.md):

- Write `/etc/fstab` ([config/fstab](../config/fstab)), `/etc/hostname`,
  `/etc/hosts`, locale, and the SysVinit **bootscripts** (network, clock,
  mountfs…).
- Configure and compile the **kernel** with `make menuconfig`. Critical detail:
  the SATA and ext4 drivers must be built **`[*]` (built-in)**, not `[M]`
  (module) — otherwise the kernel can't mount its own root filesystem and panics
  on boot. The version string is personalised via
  `CONFIG_LOCALVERSION="-everonel"`.
- Install the kernel as `/boot/vmlinuz-6.16.1-everonel` and install **GRUB** to
  the disk's MBR with a `grub.cfg` pointing at that kernel and
  `root=/dev/sda2` ([config/grub.cfg](../config/grub.cfg)).

---

## 6. How the finished system boots

Once you reboot the VM, here is the exact chain of events — a favourite
evaluation question:

```
Power on
   │
   ▼
BIOS  ──reads first sector of /dev/sda (the MBR)──▶  GRUB stage 1
   │
   ▼
GRUB  ──reads /boot/grub/grub.cfg──▶  loads vmlinuz-6.16.1-everonel
   │                                  passes root=/dev/sda2 ro
   ▼
Kernel  ── decompresses, initialises drivers, mounts / (ext4, sda2) ──▶
   │       starts the very first process, PID 1: /sbin/init
   ▼
init (SysVinit)  ── reads /etc/inittab ──▶  default runlevel 3 (multi-user)
   │                runs the S* scripts in /etc/rc.d/rc3.d/
   │                (mount filesystems, start eudev, bring up network…)
   ▼
agetty  ── spawns a login prompt on tty1–tty6 ──▶  you log in to bash
```

Each arrow is a layer from the [big-picture diagram](#2-the-big-picture-how-a-linux-system-is-born)
handing control to the one above it.

---

## 7. Anatomy of the filesystem (FHS)

The **Filesystem Hierarchy Standard** defines what lives where. LFS 12.x adopts
the "merged-`/usr`" layout, where `/bin`, `/sbin` and `/lib` are just symlinks
into `/usr`.

| Path | Purpose |
|---|---|
| `/boot` | Kernel binary, `System.map`, GRUB files. Its own partition (`sda1`). |
| `/bin`, `/sbin` | Essential commands → symlinks to `/usr/bin`, `/usr/sbin`. |
| `/lib`, `/lib64` | Shared libraries → symlink to `/usr/lib`. |
| `/usr` | The bulk of the system: programs, libraries, headers, docs. |
| `/etc` | System-wide configuration (`fstab`, `inittab`, `passwd`, `hosts`). |
| `/var` | Variable data: logs, spools, runtime state. |
| `/home` | User home directories. |
| `/root` | The root user's home. |
| `/tmp` | Temporary scratch space. |
| `/dev` | Device nodes — populated at runtime by eudev (devtmpfs). |
| `/proc` | Virtual FS exposing kernel/process state (not on disk). |
| `/sys` | Virtual FS exposing the device/driver model (sysfs). |
| `/run` | Volatile runtime data (tmpfs, cleared each boot). |

### Partition layout

The subject requires at least three partitions:

| Mount | Device | FS | Purpose |
|---|---|---|---|
| `/boot` | `/dev/sda1` | ext4 | Kernel + GRUB |
| `/` | `/dev/sda2` | ext4 | Root filesystem |
| swap | `/dev/sda3` | swap | Overflow when RAM is full |

See [config/fstab](../config/fstab) for the exact mount table, including the
virtual filesystems (`proc`, `sysfs`, `devpts`, `tmpfs`, `devtmpfs`).

---

## 8. Key subsystems explained

### The kernel
The single program that talks to hardware and arbitrates access to it. It
provides **syscalls** (the API user programs use via glibc), schedules
processes, manages memory and drives devices. The subject requires ≥ 4.0 for a
modern, stable driver/ABI surface; this build uses 6.16.1.

### Virtual filesystems: `/proc`, `/sys`, `/dev`
- **`/proc`** — a window into the kernel and every running process. `cat
  /proc/version`, `/proc/cpuinfo`, `/proc/<pid>/…`. Backed by RAM, not disk.
- **`/sys`** (sysfs) — a structured view of the device and driver model. eudev
  watches it to know what hardware exists.
- **`/dev`** — the device nodes (`/dev/sda`, `/dev/tty1`…). Populated
  dynamically at boot by **devtmpfs** + eudev, not a static directory.

### eudev — the device manager
When the kernel detects hardware it emits an event via sysfs. **eudev** (a
systemd-free fork of udev, maintained by Gentoo) catches that event, creates the
right node under `/dev`, sets permissions, and triggers `modprobe` to load the
matching driver. We use eudev specifically because the subject mandates a
**non-systemd** init.

### SysVinit — PID 1
The first userspace process the kernel starts. It reads `/etc/inittab`,
determines the default **runlevel**, and runs the start scripts for that level.
Runlevels are operating states:

| Runlevel | Meaning |
|---|---|
| 0 | Halt |
| 1 (S) | Single-user / maintenance |
| 2–5 | Multi-user (**3** = our default: full multi-user, no GUI) |
| 6 | Reboot |

### GRUB — the bootloader
**GR**and **U**nified **B**ootloader. Installed in the MBR, it's the bridge
between BIOS firmware and the kernel: it finds the kernel on `/boot`, loads it
into memory with the right parameters (`root=`, `ro`, `quiet`), and jumps into
it.

### Networking
Brought up over **DHCP** by a SysVinit bootscript, configured via
`/etc/sysconfig/ifconfig.eth0`. `iproute2` provides `ip addr` / `ip route`.
Verify with `ping -c3 8.8.8.8`.

### "Installing software" without a package manager
LFS has **no** apt/dnf/pacman. Installing anything means the source dance:

```bash
wget https://example.org/pkg-1.0.tar.gz
tar -xf pkg-1.0.tar.gz && cd pkg-1.0/
./configure --prefix=/usr   # detect the system, generate a Makefile
make                        # compile sources → binaries (stay in build dir)
make install                # copy binaries/libs/headers/man into /usr
```

`make` builds; `make install` *places* the build under `--prefix`. Two distinct
steps on purpose.

### Inspecting the result
- `ldd /bin/bash` — list a binary's shared-library dependencies (confirms it
  links against **LFS** libs, not host ones).
- `strip` — remove debug symbols to shrink binaries 50–80 %; run in bulk at the
  end of the temporary-tools stage to save disk.
- `uname -r` → `6.16.1-everonel`; `runlevel` → `3`; `lsmod` → loaded modules.

A fuller Q&A list lives in [`notes/cheatsheet.md`](../notes/cheatsheet.md).

---

## 9. Repository layout

```
ft_linux/
├── README.md                 # quick-start + project card
├── checksum.txt              # SHA of the final disk image (for evaluation)
├── wget-list-sysv            # every upstream source URL
├── config/                   # reference system configs
│   ├── fstab                 #   mount table
│   ├── grub.cfg              #   bootloader config
│   └── kernel.config         #   saved `make menuconfig` answers
├── scripts/
│   ├── 01_setup/             # host prep: version check, partition, env, sources
│   └── 02_build/
│       ├── 01_run_compiler_toolchain.sh   ──▶ compiler-toolchain/
│       ├── 02_run_temporary_tools.sh      ──▶ temporary-tools/
│       ├── 03_enter_chroot.sh             ──▶ (host: mounts + chroot)
│       ├── 04_run_chroot_tools.sh         ──▶ chroot-tools/
│       └── 05_run_final_system.sh         ──▶ final-system/   (~78 pkgs)
├── notes/
│   ├── cheatsheet.md         # evaluation Q&A — read before defense
│   ├── issues.md             # problems hit and how they were fixed
│   └── steps/                # detailed, narrated walkthrough of every chapter
└── docs/
    └── DOCUMENTATION.md      # ← you are here
```

Each per-package script is numbered to encode the **global build order** — that
ordering *is* the dependency graph, and breaking it breaks the build.

---

## 10. Running the build yourself

> ⚠️ This takes hours and a lot of disk. Do it in a VM, never on a machine you
> care about — a misfired `make install` as root can damage the host.

**Prerequisites:** VirtualBox/VMware, x86_64 host (≥ 4 cores), ≥ 8 GB RAM,
≥ 30 GB disk, and a host that passes LFS `version-check.sh`.

```bash
# ── Stage 0: host prep (as root, then as the lfs user) ──
sudo bash scripts/01_setup/00_version_check.sh
sudo bash scripts/01_setup/01_disk_partition.sh /dev/sdb
sudo bash scripts/01_setup/02_env_setup.sh
sudo su - lfs
bash scripts/01_setup/03_download_sources.sh

# ── Stages 1–2: toolchain + temporary tools (as lfs) ──
bash scripts/02_build/01_run_compiler_toolchain.sh   # resume: … <N>
bash scripts/02_build/02_run_temporary_tools.sh

# ── Stage 3: enter chroot (root on host) ──
sudo bash scripts/02_build/03_enter_chroot.sh
# now inside the chroot, as root:
bash /sources/scripts/04_run_chroot_tools.sh

# ── Stage 4: final system (inside chroot) ──
bash /sources/scripts/05_run_final_system.sh
#   step 25 (shadow) prompts for the root password — interactive
#   step 26 (gcc) is the longest; resume after with: … 26
```

Then follow [`notes/steps/build/10_system_config.md`](../notes/steps/build/10_system_config.md)
and [`11_kernel_bootloader.md`](../notes/steps/build/11_kernel_bootloader.md) to
configure the system, compile the kernel, and install GRUB. Reboot — and you're
running a Linux distribution you built from source.

If something breaks, [`notes/issues.md`](../notes/issues.md) catalogues the real
problems this build hit (host DNS, `/bin/sh`→dash, GCC 15 / C23 breakage, the
module-vs-built-in kernel panic, …) and their fixes.

---

## 11. Glossary

| Term | Meaning |
|---|---|
| **LFS** | Linux From Scratch — the source-only build methodology this follows. |
| **Toolchain** | binutils + gcc + glibc; the machinery that turns source into binaries. |
| **Bootstrapping** | Using a system to build (a better version of) itself. |
| **Cross-compiler** | Compiler that runs on host A but emits binaries for target B. |
| **Triplet** | `arch-vendor-kernel-abi` string identifying a binary's target. |
| **`$LFS`** | The mount point of the new system during the build (`/mnt/lfs`). |
| **`$LFS_TGT`** | The build's fake target triplet, `x86_64-lfs-linux-gnu`. |
| **chroot** | Syscall that changes a process's apparent root directory. |
| **glibc** | GNU C Library — the syscall-wrapping runtime every C program needs. |
| **syscall** | A request from a user program into the kernel. |
| **ABI** | Application Binary Interface — the binary contract between compiled parts. |
| **FHS** | Filesystem Hierarchy Standard — the standard directory layout. |
| **init / PID 1** | The first userspace process; parent of all others. |
| **Runlevel** | A SysVinit operating state (0 halt … 3 multi-user … 6 reboot). |
| **MBR** | Master Boot Record — first disk sector, holds GRUB stage 1. |
| **udev/eudev** | Userspace daemon that manages `/dev` dynamically. |
| **devtmpfs / sysfs / procfs** | Virtual, RAM-backed filesystems exposing devices/kernel state. |
| **strip** | Remove debug symbols to shrink binaries. |
| **ldd** | List a binary's shared-library dependencies. |

---

## 12. References

- [Linux From Scratch (LFS) book](https://www.linuxfromscratch.org/lfs/) — the canonical guide.
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml)
- [The GNU toolchain](https://gcc.gnu.org/) · [Glibc](https://www.gnu.org/software/libc/)
- [kernel.org](https://www.kernel.org/) — kernel sources & docs.
- [Software-Building HOWTO](https://tldp.org/HOWTO/Software-Building-HOWTO.html)
- Local: [`notes/cheatsheet.md`](../notes/cheatsheet.md) · [`notes/issues.md`](../notes/issues.md) · [`notes/steps/`](../notes/steps/)

---

*42 School — RNCP7 · Unix/Kernel · ft_linux*
