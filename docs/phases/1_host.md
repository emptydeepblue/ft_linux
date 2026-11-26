# Phase 1 — Host, disk, sources, lfs user

**Book:** LFS 12.4 ch. 2–4 · **Folder:** [`build/1_host/`](../../build/1_host/) ·
**Who/where:** root on the host, one script at a time · **Status:** reviewed against the book, built (2026-11-25)

LFS needs an existing Linux, the **host**, whose compiler builds the first
toolchain. Here it is WSL2 with Ubuntu 22.04, the same OS as the school PCs.
This phase prepares the host, the target disk, the sources and an unprivileged
build user.

*Why WSL2 and not a VirtualBox VM as host:* on this PC VirtualBox runs on top of
Hyper-V (Docker Desktop) and compiles very slowly; WSL2 is itself a light Hyper-V
VM and compiles at near-native speed. The classic way (a host VM with a second
virtual disk) also works: set `LFS_DISK=/dev/sdb` in `config/ft_linux.local.conf`.

```bash
sudo bash build/1_host/01_host_prepare.sh
sudo bash build/1_host/03_disk_partition.sh
sudo bash build/1_host/04_download_sources.sh
sudo bash build/1_host/05_lfs_user.sh
sudo bash build/lfs_disk.sh mount        # only after a WSL/host restart
```

## Steps

| Script | Book | What it does and why |
|---|---|---|
| `01_host_prepare.sh` | §2.2 | apt installs the build tools; `sh`→bash, `awk`→gawk, `yacc`→bison (LFS assumes the GNU tools, Ubuntu defaults to dash/mawk); then runs `02`. |
| `02_version_check.sh` | §2.2 | The book's script, unchanged: every line must say `OK`. |
| `03_disk_partition.sh` | §2.4–2.7 | Creates the target disk and mounts it on `/mnt/lfs` (see below). |
| `04_download_sources.sh` | ch. 3 | Downloads the official `wget-list-sysv` 12.4 (minus systemd/D-Bus) + [`config/extra-sources.list`](../../config/extra-sources.list) into `$LFS/sources` (mode 1777, like `/tmp`) and checks every md5. A file whose upstream URL is gone, or whose md5 is wrong, is fetched again from the LFS package archive (`LFS_MIRROR`). Fails if anything is still missing. Safe to re-run. |
| `05_lfs_user.sh` | ch. 4 | Minimal layout (`/usr/{bin,lib,sbin}`, `bin lib sbin` → `usr/*`, `lib64`, `tools`), user `lfs` owning only what it installs into, its clean environment, and a copy of `build/` + `config/` it can read. |

## The disk

The disk is a **raw image file** (`/var/lib/ft_linux/ft_linux.img`, sparse, 30 GB),
attached to a loop device. WSL has no spare physical disk, and at the end the
file becomes `ft_linux.vdi` with a single `qemu-img convert`.
`build/lfs_disk.sh mount|umount|detach|status` handles it. Loop devices do not
survive a WSL restart, the file does.

| Part. | Size | FS | Mounted on | Why |
|---|---|---|---|---|
| p1 | 512 MB | ext4 | `/boot` | kernel + GRUB, separate as the subject requires |
| p2 | rest (~27.5 GB) | ext4 | `/` | the system |
| p3 | 2 GB | swap | — | required by the subject |

The table is MBR (dos), because GRUB is installed for BIOS (`i386-pc`), the
default firmware of a VirtualBox VM. Sizes come from
[`config/ft_linux.conf`](../../config/ft_linux.conf).
With `LFS_DISK=/dev/sdX` the same script partitions a real disk instead.

## The lfs user and its environment

Chapters 5–6 run as `lfs`, not root: a mistake can only damage `$LFS`, never
the host. Its shell starts **empty** (`exec env -i` in `.bash_profile`) and
`.bashrc` sets only:

| Variable | Why |
|---|---|
| `LFS=/mnt/lfs` | where the new system lives |
| `LFS_TGT=x86_64-lfs-linux-gnu` | a target triplet different from the host's, so the build is treated as a cross-compilation |
| `PATH=$LFS/tools/bin:/usr/bin:/bin` | the new cross-tools win over the host's as soon as they exist |
| `set +h` | no command hashing, so new tools are found immediately |
| `LC_ALL=POSIX`, `umask 022` | predictable output and permissions |
| `CONFIG_SITE=$LFS/usr/share/config.site` | stops configure from reading the host's site file |
| `MAKEFLAGS=-j$JOBS` | parallel builds (all cores) |
| `FT_DIR=$LFS/sources/ft_linux` | where the scripts are (the repo in `/home` is not readable by lfs) |

## Deviations from the book

- **`/etc/bash.bashrc` of the host is not moved away** (§4.4 suggests it).
  On Ubuntu it only defines prompt and helper functions and exports nothing,
  so the build scripts, which run as non-interactive `bash`, never see it.
  Moving it would break the everyday shells of the WSL host.
- **Sources are downloaded by root before `lfs` exists** (book order: ch. 3
  then ch. 4); the extra tarballs (eudev, check, BLFS networking) come from
  `config/extra-sources.list`, all with md5 except three that publish none.

## Check

`05_lfs_user.sh` prints the layout and ownership at the end. Then:

```bash
sudo su - lfs
echo $LFS $LFS_TGT $MAKEFLAGS     # /mnt/lfs x86_64-lfs-linux-gnu -j16
```

Next: [Phase 2 — toolchain](2_toolchain.md).
