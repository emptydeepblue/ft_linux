# Phases 3–4 — Entering the chroot, last temporary tools

**Book:** LFS 12.4 ch. 7 · **Folders:** [`build/3_chroot/`](../../build/3_chroot/),
[`build/4_chroot_tools/`](../../build/4_chroot_tools/) · **Status:** reviewed against the book

| Phase | Who/where | |
|---|---|---|
| 3_chroot | root on the **host** | hand `$LFS` to root, mount the kernel file systems, enter |
| 4_chroot_tools | root **inside** the chroot | directories, essential files, 6 packages, cleanup |

```bash
sudo bash build/3_chroot/01_chown_root.sh       # once, after phase 2
sudo bash build/3_chroot/02_enter_chroot.sh     # every time (also after a WSL restart)
# now inside, prompt "(lfs chroot)":
bash $FT_DIR/build/4_chroot_tools/run.sh        # resumable: run.sh 7.10
```

## Why a chroot

From here on, every program must come from `$LFS`, none from the host.
`chroot $LFS` makes `/mnt/lfs` the `/` of a shell: the host's files are no
longer visible, and only the temporary tools from phase 2 can run. It is the
same kernel (the host's), but a new root, with a clean environment
(`env -i`, `PATH=/usr/bin:/usr/sbin`). If something still referred to the host,
it would fail here, not later on the finished system.

## 3_chroot

| Script | Book | What and why |
|---|---|---|
| `01_chown_root.sh` | §7.2 | Everything built by `lfs` becomes root's: the UID of `lfs` does not exist inside ft_linux, so its files would belong to a random user. `chown --from lfs`: touches only files still owned by lfs, so running it twice is harmless. |
| `02_enter_chroot.sh` | §7.3–7.4 | Mounts `/dev` (bind of the host's), `/dev/pts`, `/proc`, `/sys`, `/run`, `/dev/shm` inside `$LFS`: programs need them, and only the running kernel can provide them. Copies `build/` + `config/` to `/sources/ft_linux` (`$FT_DIR`), then `chroot`. Refuses to run if §7.2 was not done. Mounts are lost at every WSL restart: run it again. |

## 4_chroot_tools

| Step | What and why |
|---|---|
| 7.5 Directories | The FHS tree (`/etc`, `/usr/share/man/man1..8`, `/var/lib`, `/tmp` 1777, `/root` 0750…), `/var/run` → `/run`. |
| 7.6 Essential files | `/etc/passwd` and `/etc/group` (root plus the system users and groups that packages expect), `/etc/mtab` → `/proc/self/mounts`, the login log files. Until the shell is restarted the prompt shows `I have no name!`: harmless. |
| 7.7 Gettext | Only `msgfmt`, `msgmerge`, `xgettext`: many configure scripts need them. |
| 7.8 Bison, 7.11 Texinfo | Needed to build packages of ch. 8 (Glibc needs Bison). |
| 7.9 Perl | Temporary Perl (shared `libperl`), needed by many build systems. |
| 7.10 Python | Temporary Python: Glibc's build in ch. 8 runs Python scripts. |
| 7.12 Util-linux | `mount`, `fdisk`, `libuuid`… needed by later packages. |
| 7.13 Cleanup | Removes documentation, `.la` files and **`/tools`**: the cross-toolchain is never used again. |

## Deviations from the book

- **No `tester` user** (§7.6): it only runs test suites as non-root, and this
  build does not run them (the one test kept, in Eudev, runs as root).
- **`/etc/hosts`** without the hostname here: written for good in phase 6.
- `01_chown_root.sh` also gives `$LFS/sources` to root: leftover build
  directories and logs written by `lfs` live there.
- A minimal `/etc/bash.bashrc` (aliases, prompt) for root's shell.
- Not done: the optional backup of the temporary system (§7.13).

## What the review fixed (2026-11-23)

- **Perl:** `-D useshrplib` was missing (no shared `libperl`).
- **Cleanup:** did not remove `/tools`; instead it stripped every library
  (with exceptions to avoid breaking `as`) and deleted `include-fixed` through
  a path wrong for GCC 15. Now it does exactly what §7.13 says.
- **§7.5:** `/usr/lib/locale` was missing (Glibc installs locales there in ch. 8).
- **§7.6:** an extra group `sgx:x:101` that 12.4 does not have.
- **§7.2:** limited to the book's directories (+ `sources`); `TESTSUITEFLAGS` set like §7.4.
- Options of every package and the directory list were compared with the book
  automatically: no differences left.

## Check

```bash
ls -ld /tools                       # must not exist any more
perl -V:useshrplib                  # useshrplib='true';
python3 --version                   # Python 3.13.7
```

Next: [Phase 5 — final system](5_final_system.md).
