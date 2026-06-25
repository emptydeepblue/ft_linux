# ft_linux — Evaluation Cheatsheet

---

## Quick reference — your system

| Item | Value |
|---|---|
| Kernel version | `6.16.1-everonel` |
| Hostname | `everonel` |
| Init system | SysV init (`/sbin/init`) |
| Module loader | eudev |
| Bootloader | GRUB2 |
| Root partition | `/dev/sda2` (ext4) |
| Boot partition | `/dev/sda1` (ext4) |
| Swap partition | `/dev/sda3` |
| Kernel sources | `/usr/src/kernel-6.16.1` |
| Kernel binary | `/boot/vmlinuz-6.16.1-everonel` |
| LFS version | 12.4 |
| GCC version | 15.2.0 |
| Glibc version | 2.42 |

---

## Useful commands to run during evaluation

```bash
uname -r                        # kernel version → 6.16.1-everonel
uname -a                        # full kernel info
hostname                        # everonel
cat /etc/hostname
lsblk                           # partition layout
fdisk -l /dev/sda               # detailed partition table
free -h                         # RAM + swap
df -h                           # disk usage
ip addr                         # network interfaces
ping -c 3 8.8.8.8               # internet connectivity
cat /proc/version               # kernel version from /proc
ls /boot/                       # vmlinuz, System.map, config, grub/
ls /usr/src/                    # kernel sources
cat /boot/grub/grub.cfg         # bootloader config
cat /etc/inittab                # SysV init config
runlevel                        # current runlevel (should be 3)
ps aux | head                   # running processes
lsmod                           # loaded kernel modules
udevadm info --version          # eudev version
```

---

## Subject requirements — verified answers

### Why a virtual machine?
The subject requires it. Using VirtualBox — the LFS system runs on a dedicated virtual disk, completely separate from the host.

### What kernel version? Why >= 4.0?
`6.16.1-everonel`. The subject requires >= 4.0 for modern driver support and stable API. We used 6.16.1 (current stable).

### Where are the kernel sources?
`/usr/src/kernel-6.16.1` — subject requirement, not a default location. Placed there manually after extraction.

### How is your login in the kernel version?
`CONFIG_LOCALVERSION="-everonel"` set in `make menuconfig` under General setup → Local version. Result: `uname -r` returns `6.16.1-everonel`.

### What partitions do you have? Why 3?
- `/dev/sda1` → `/boot` (ext4) — bootloader and kernel binary
- `/dev/sda2` → `/` (ext4) — root filesystem
- `/dev/sda3` → swap — virtual memory when RAM is exhausted
Subject requires at least 3 partitions.

### What is your kernel module loader?
**eudev** — a fork of udev that works without systemd. Manages `/dev` dynamically: when hardware is detected, eudev creates the corresponding device node and loads the appropriate module via `modprobe`.

### What init system? How does it work?
**SysV init** (`sysvinit`). Process:
1. Kernel starts `/sbin/init`
2. `init` reads `/etc/inittab` to find the default runlevel (3 = multi-user)
3. Executes `/etc/rc.d/init.d/rc 3` which runs all `S*` scripts in `/etc/rc.d/rc3.d/`
4. Spawns `agetty` on tty1–6 for login prompts

### What bootloader? How does it work?
**GRUB2** (Grand Unified Bootloader). Installed to the MBR of `/dev/sda`. At boot:
1. BIOS loads GRUB stage 1 from MBR
2. GRUB reads `/boot/grub/grub.cfg`
3. Loads `vmlinuz-6.16.1-everonel` with `root=/dev/sda2`
4. Kernel takes over

### Where is the kernel binary? Why that name?
`/boot/vmlinuz-6.16.1-everonel` — subject requirement: *"vmlinuz-\<linux_version\>-\<student_login\>"*.

### How to connect to the internet?
Using DHCP via the lfs-bootscripts network init script. Interface config in `/etc/sysconfig/ifconfig.eth0`. After boot: `ip addr` shows the assigned IP, `ping 8.8.8.8` verifies connectivity.

### How would you install a new package?
LFS has no package manager — everything is built from source:
```bash
wget https://example.com/pkg-1.0.tar.gz
tar -xf pkg-1.0.tar.gz && cd pkg-1.0/
./configure --prefix=/usr
make
make install
```

---

## Core concepts — theory questions

### What is Linux From Scratch?
A project that provides instructions to build a Linux system entirely from source code. No binary packages — every tool, library, and the kernel itself is compiled on the host. Result: a minimal, fully understood system.

### What is a cross-compiler? Why did you build one?
A compiler that runs on machine A but produces binaries for machine B. We built one (targeting `x86_64-lfs-linux-gnu`) to bootstrap the toolchain independently of the host system — ensuring no host library contamination in the final LFS system.

### What is chroot? Why did you use it?
`chroot` changes the apparent root directory for a process. Used to enter the partially-built LFS system and continue building as if we were running natively on it, while still using the host kernel. The `$LFS/tools` cross-compiler was replaced by native tools after entering chroot.

### What is glibc? Why is it first?
The GNU C Library — the interface between user programs and the Linux kernel. Almost every program links against it. Built first in the final system because everything else depends on it.

### What is /proc? /sys? /dev?
- `/proc` — virtual FS, exposes kernel internal state (processes, memory, CPU info). Not on disk.
- `/sys` — virtual FS, exposes device and driver model (sysfs). Used by udev.
- `/dev` — device nodes. eudev populates this dynamically at runtime via devtmpfs.

### What is a runlevel?
A SysV concept defining the system's operating state:
- 0 — halt
- 1 — single user (maintenance)
- 2–5 — multi-user (3 = our default, no GUI)
- 6 — reboot

### What is swap?
Disk space used as overflow when physical RAM is exhausted. The kernel moves inactive memory pages to swap, freeing RAM for active processes. Slower than RAM but prevents OOM kills.

### What is FHS (Filesystem Hierarchy Standard)?
Defines the directory structure and purpose of directories in Unix-like systems:
- `/bin`, `/sbin` → essential binaries (now symlinks to `/usr/bin`, `/usr/sbin` in LFS 12.x)
- `/etc` → system configuration
- `/usr` → user programs and libraries
- `/var` → variable data (logs, spools)
- `/boot` → kernel and bootloader files
- `/lib` → libraries (symlink to `/usr/lib` in LFS 12.x)
- `/home` → user home directories
- `/tmp` → temporary files

### What is the difference between `make` and `make install`?
- `make` — compiles the source into binaries (stays in build directory)
- `make install` — copies the compiled binaries, libraries, headers, and man pages to their final locations under `--prefix` (usually `/usr`)

### What is eudev vs udev vs systemd-udev?
All three implement the same udev interface for dynamic device management. `systemd-udev` is bundled with systemd. `eudev` is a standalone fork maintained by Gentoo — works with any init system including SysV. We chose eudev because the subject requires a non-systemd init (sysvinit).

### What is `ldd`? What does it show?
Lists the shared library dependencies of a binary:
```bash
ldd /bin/bash
# shows: libreadline.so, libdl.so, libc.so → all under /usr/lib
```
Useful to verify binaries link against LFS libraries, not the host's.

### What is `strip`? Why use it?
Removes debug symbols from binaries and libraries, reducing their size significantly (often 50–80%). LFS runs a strip pass at the end of the temporary tools phase to free disk space before building the final system.

---

## Common pitfalls — known issues in this build

| Issue | Cause | Fix |
|---|---|---|
| `true`/`false` undeclared | GCC 15 defaults to C23 (keywords, not macros) | Add `-std=c11` to CFLAGS |
| `stdbool.h` missing | GCC 15 removed implicit inclusion | Add `#include <stdbool.h>` |
| `sysklogd` wrong build commands | Version 2.x uses autoconf, not bare Makefile | Use `./autogen.sh && ./configure` |
| `bc: command not found` during kernel build | bc not in PATH or not built | Rebuild bc with `-std=c11` |
| `/etc/inittab` missing | lfs-bootscripts installs fragments, not the file | Create manually |
| Kernel panic: can't mount root | SATA/ext4 driver compiled as module, not built-in | Rebuild with `[*]` not `[M]` |
| `libbfd too short` | strip crashed mid-write on libbfd | Rebuild binutils from host |

---

## Checksum generation (submission)

```bash
# VM must be shut down first
shasum < ~/VirtualBox\ VMs/ft_linux/ft_linux.vdi > checksum.txt
# or
md5sum ~/VirtualBox\ VMs/ft_linux/ft_linux.vdi > checksum.txt
```
