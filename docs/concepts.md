# ft_linux — Concepts

> Build a complete, bootable Linux distribution from nothing but source code —
> compiler, C library, kernel, init system and userland — following the
> [Linux From Scratch](https://www.linuxfromscratch.org/) (LFS 12.4) methodology.
>
> **42 School · RNCP7 · Unix/Kernel** 

The *why* behind the build: what each piece is and how it all fits together.
How to run it is in the [README](../README.md); each phase in [phases/](phases/).

---

## Table of contents

1. [What this project actually is](#1-what-this-project-actually-is)
2. [The big picture: how a Linux system is born](#2-the-big-picture-how-a-linux-system-is-born)
3. [Why you can't just "compile Linux"](#3-why-you-cant-just-compile-linux--the-bootstrapping-problem)
4. [The toolchain — the heart of the build](#4-the-toolchain--the-heart-of-the-build)
5. [The build, phase by phase](#5-the-build-phase-by-phase)
6. [How the finished system boots](#6-how-the-finished-system-boots)
7. [Anatomy of the filesystem (FHS)](#7-anatomy-of-the-filesystem-fhs)
8. [Key subsystems explained](#8-key-subsystems-explained)
9. [Glossary](#9-glossary)
10. [References](#10-references)

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

## 5. The build, phase by phase

Each folder of [`build/`](../build/) is one phase, documented in
[`phases/`](phases/) — what it does, why, and where it departs from the book:

| Phase | Book | In one line |
|---|---|---|
| [1_host](phases/1_host.md) | ch. 2–4 | host tools, disk image, sources, the unprivileged `lfs` user |
| [2_toolchain](phases/2_toolchain.md) | ch. 5–6 | cross-compiler into `$LFS/tools`, then a minimal userland cross-compiled into `$LFS` |
| [3–4 chroot](phases/3-4_chroot.md) | ch. 7 | hand `$LFS` to root, enter it with `chroot`, build the last temporary tools |
| [5_final_system](phases/5_final_system.md) | ch. 8 | every package rebuilt natively, the real system |
| [6–7 boot, network](phases/6-7_boot_network.md) | ch. 9–10 + BLFS | bootscripts, `/etc`, kernel, GRUB; CA certificates, wget, dhcpcd, ssh |

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
   │                                  passes root=PARTUUID=… ro (= /dev/sda2)
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

See `build/6_boot/02_system_config.sh` for the exact mount table, including the
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

A fuller Q&A list lives in [`cheatsheet.md`](cheatsheet.md).

---

## 9. Glossary

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

## 10. References

- [Linux From Scratch (LFS) book](https://www.linuxfromscratch.org/lfs/) — the canonical guide.
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml)
- [The GNU toolchain](https://gcc.gnu.org/) · [Glibc](https://www.gnu.org/software/libc/)
- [kernel.org](https://www.kernel.org/) — kernel sources & docs.
- [Software-Building HOWTO](https://tldp.org/HOWTO/Software-Building-HOWTO.html)
- Local: [`cheatsheet.md`](cheatsheet.md) · [`issues.md`](issues.md) · [`phases/`](phases/)

---

*42 School — RNCP7 · Unix/Kernel · ft_linux*
