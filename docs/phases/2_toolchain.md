# Phase 2 — Cross-toolchain and temporary tools

**Book:** LFS 12.4 ch. 5–6 · **Folder:** [`build/2_toolchain/`](../../build/2_toolchain/) ·
**Who/where:** user `lfs` on the host · **Status:** reviewed against the book

```bash
sudo su - lfs
bash $FT_DIR/build/2_toolchain/run.sh          # everything (≈ 30–60 min)
bash $FT_DIR/build/2_toolchain/run.sh 5 5      # only chapter 5
bash $FT_DIR/build/2_toolchain/run.sh 6.10     # resume at Grep after a failure
```

`run.sh` first runs [`check_env.sh`](../../build/2_toolchain/check_env.sh)
(user, variables, mounts, free space, tarballs, host compiler), then every
step in book order. Logs: `$LFS/sources/logs/2_toolchain/`.

## Why two chapters

The host's compiler cannot be trusted to build the new system: its output
depends on the host's own libraries and headers. So the build goes through
a **cross-compiler** whose target, `x86_64-lfs-linux-gnu`, differs from the
host's `x86_64-pc-linux-gnu` even though both are x86_64. Because the targets
differ, nothing from the host's `/usr` can leak into what it produces.

- **Ch. 5** builds that cross-toolchain into `$LFS/tools` and the C library
  it targets, into `$LFS`.
- **Ch. 6** uses it to cross-compile a minimal userland into `$LFS`: just
  enough (shell, coreutils, make, a native compiler…) to work inside a
  `chroot` without the host in phase 3.

## Chapter 5 — the cross-toolchain

| Step | What and why |
|---|---|
| 5.2 Binutils pass 1 | Cross assembler and linker (`$LFS_TGT-as`, `-ld`). First, because GCC and Glibc check them at configure time. `--with-sysroot=$LFS`: the linker looks for libraries in `$LFS`, never in the host's `/usr/lib`. |
| 5.3 GCC pass 1 | A minimal cross-compiler: C/C++ only, no shared libgcc, no threads, because there is no C library to link against yet (`--with-newlib --without-headers`). GMP/MPFR/MPC are built inside the GCC tree. The `t-linux64` sed puts 64-bit libraries in `lib`, not `lib64`. Ends by writing a complete `limits.h`. |
| 5.4 Linux API headers | `make headers`: the kernel's syscall interface, which Glibc is compiled against. Only `.h` files are copied. |
| 5.5 Glibc | The C library, cross-compiled and installed into `$LFS`. The FHS patch moves runtime data to `/var/lib`. `--enable-kernel=5.4` is the oldest kernel it will support. The **sanity check** compiles an empty program and requires the ELF interpreter `/lib64/ld-linux-x86-64.so.2`: anything else means a broken toolchain, and the script stops. |
| 5.6 Libstdc++ | The C++ library, which GCC pass 1 could not build without Glibc. |

## Chapter 6 — temporary tools

Every package is configured with `--host=$LFS_TGT` (built by the
cross-compiler) and installed with `DESTDIR=$LFS`.

| Step | Notes |
|---|---|
| 6.2 M4, 6.5 Coreutils, 6.6 Diffutils, 6.8 Findutils, 6.9 Gawk, 6.10 Grep, 6.11 Gzip, 6.12 Make, 6.13 Patch, 6.14 Sed, 6.15 Tar, 6.16 Xz | Plain cross-builds. Coreutils moves `chroot` to `/usr/sbin`; Gawk skips its `extras`; Xz and others delete `.la` files (they would point libtool at wrong paths later). |
| 6.3 Ncurses | First builds a `tic` that runs on the host (into `$LFS/tools/bin`), needed by `make install` to compile the terminal database. |
| 6.4 Bash | Plus the `/bin/sh` → `bash` link. |
| 6.7 File | Same trick as Ncurses: a host `file` first, because building the magic database needs the same version of `file`. |
| 6.17 Binutils pass 2 | Native binutils for inside the chroot. The `ltmain.sh` sed (line **6031** in 12.4) stops libtool from linking against the host's libraries. |
| 6.18 GCC pass 2 | Native GCC for inside the chroot, now with threads and shared libraries (the `gthr-posix.h` sed); `cc` → `gcc`. |

## What the review fixed (2026-11-23)

These would all have failed or produced a broken toolchain:

- **Binutils pass 2:** `ltmain.sh` sed on line 6009 (old book) → **6031**.
- **GCC pass 1 and 2:** MPC is a `.tar.gz` in 12.4, the scripts looked for `.tar.xz`;
  `--with-glibc-version=2.40` → **2.42**; pass 2 lacked `--disable-libsanitizer`.
- **Glibc:** the FHS patch was missing; `--enable-kernel=4.19` → **5.4**.
- **Ncurses:** a `.tgz` in 12.4; the host `tic` is now built as in 12.4 (`AWK=gawk`,
  installed into `$LFS/tools`, no `TIC_PATH`).
- **Make:** `make-*.tar.gz` also matched `make-ca-*.tar.gz` (BLFS): now `make-[0-9]*`.
- **Libstdc++:** quoted braces made the `.la` cleanup a no-op.
- Removed options the 12.4 book does not use (Bash, Diffutils, Make).

The options of every script were then compared with the book automatically:
the only differences left are equivalent (computed version strings, the Glibc
sanity check).

## Check

At the end `run.sh` prints the book's toolchain test (§5.5):

```bash
echo 'int main(){}' | $LFS_TGT-gcc -xc - && readelf -l a.out | grep interpreter
# [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
```

Next: [Phase 3–4 — chroot](3-4_chroot.md).
