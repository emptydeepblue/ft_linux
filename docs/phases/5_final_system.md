# Phase 5 — The final system

**Book:** LFS 12.4 ch. 8 · **Folder:** [`build/5_final_system/`](../../build/5_final_system/) ·
**Who/where:** root inside the chroot · **Status:** reviewed against the book (all of ch. 8)

```bash
bash $FT_DIR/build/5_final_system/run.sh          # all of ch. 8, unattended (hours)
bash $FT_DIR/build/5_final_system/run.sh --list   # the 83 steps
bash $FT_DIR/build/5_final_system/run.sh 8.29     # resume at GCC
```

Every package is now built **natively**, by the compiler of phase 2, and
installed into `/usr` of the new system, replacing the temporary tools. The
file names are the book sections, so the order is the book's dependency order.
Which subject package is built where: [packages.md](../packages.md).

## Choices that apply to the whole chapter

- **No test suites** (`make check`): they take hours, and need the `tester` user
  for some packages. The book marks the Glibc, GCC, Binutils and GMP suites
  as critical. Here the checks are the sanity tests that stop the build:
  the ELF interpreter after Glibc (§5.5) and after GCC (§8.29).
- **Portable binaries:** nothing is tuned for the build machine's CPU, so the
  image runs on any x86-64 PC (otherwise: *Illegal instruction* at school).
  GMP needs `--host=none-linux-gnu` for this (see below).
- **Unattended:** the only interactive step of the book (`passwd root` after
  Shadow) is moved to [phase 6](6-7_boot_network.md).

## 8.3–8.29 — base libraries and the native toolchain

| Step | What and why |
|---|---|
| 8.3 Man-pages | The manual pages (`crypt*` ones removed: Libxcrypt installs better ones). |
| 8.4 Iana-Etc | `/etc/services`, `/etc/protocols`: port and protocol names for the network code. |
| 8.5 **Glibc** | The final C library. FHS patch and the 2.42 `abort()` fix; libraries replaced through a `DESTDIR` copy first (overwriting a libc in use can crash running programs); GCC's `limits.h` moved out of `include-fixed`. Then: the book's set of **locales** (`C.UTF-8`, `en_US`, `it_IT`… checked at the end), `nsswitch.conf`, **time zone data** (a subject item) with `/etc/localtime` → UTC, `ld.so.conf` with `ld.so.conf.d/`. |
| 8.6 Zlib, 8.7 Bzip2, 8.8 Xz, 8.9 Lz4, 8.10 Zstd | Compression libraries and tools. Bzip2 is built twice to get a shared `libbz2`. |
| 8.11 File, 8.12 Readline, 8.13 M4, 8.14 Bc, 8.15 Flex | Readline: line editing for Bash. Flex also provides `lex`. Bc is needed by the kernel build. |
| 8.16 Tcl, 8.17 Expect, 8.18 DejaGNU | The test framework (subject items). Tcl's `*Config.sh` are rewritten to point to `/usr`, not the build tree. Expect first checks that PTYs work. |
| 8.19 Pkgconf | Drop-in replacement for `pkg-config` (the subject's item), with that name as a link. |
| 8.20 Binutils | Final linker and assembler, built against the system zlib. |
| 8.21 GMP, 8.22 MPFR, 8.23 MPC | Math libraries for GCC. **GMP with `--host=none-linux-gnu`**: generic code instead of code for this CPU. |
| 8.24 Attr, 8.25 Acl, 8.26 Libcap | Extended attributes, access control lists, POSIX capabilities. |
| 8.27 Libxcrypt | Password hashing (yescrypt), used by Shadow. |
| 8.28 Shadow | `passwd`, `useradd`, `login.defs` with yescrypt; shadowed passwords (`pwconv`, `grpconv`); new users get group `users` (999). |
| 8.29 **GCC** | The final compiler (30–90 min). Then the book's sanity check: an empty program must use `/lib64/ld-linux-x86-64.so.2` and the new start files, or the build stops. LTO plugin linked for binutils. |

### What the review fixed (8.3–8.29, 2026-11-23)

- **Glibc:** missing the `abort()` fix, the safe `DESTDIR` library copy, the
  `limits.h` move and `ld.so.conf.d`; `--enable-kernel=4.19` → **5.4**; it built
  *all* locales (slow, ~200 MB more in the image) → the book's set, with
  `localedef` warnings no longer stopping the build.
- **Tcl:** `SRCDIR` was set with an unexpanded glob, so the config-file fixes
  did nothing; `--disable-rpath`, the tdbc/itcl fixes, `chmod` and the
  `Thread.3` rename were missing. Rewritten from the book.
- **Expect:** wrong library link (`/usr/lib/expect` instead of
  `libexpect5.45.4.so`), missing `--disable-rpath`, added the PTY check.
- **GMP:** a hand-made compiler wrapper in `/tmp` replaced by the book's one-line
  GCC 15 fix; **`--host=none-linux-gnu`** added (portability).
- **Shadow:** it deleted man page *sources*, which would break
  `make install-man` → the book's `Makefile.in` edits; `useradd -D` defaults added.
- **Binutils:** `--enable-gold` removed (gold no longer exists in binutils).
- **Bc, Bzip2, Man-pages, Libxcrypt:** options aligned with the book.
- **GCC:** the sanity check now stops the build on a wrong interpreter.
- In the whole chapter, 17 `--docdir` built by reading version files
  (`$(cat configure | grep …)`) → the directory name `${PWD##*/}`.

Options of every script compared with the book automatically: the only
differences left are the choices above.

## 8.30–8.58 — userland, build systems, Python, kmod

| Step | What and why |
|---|---|
| 8.30 Ncurses | Final terminal library, wide-character (`libncursesw`), with links so programs asking for `-lncurses` get it. Installed through `DESTDIR` like Glibc: the old library is in use. |
| 8.31 Sed, 8.32 Psmisc, 8.35 Grep, 8.36 Bash | Core userland. Psmisc: `killall`, `pstree`. |
| 8.33 Gettext, 8.34 Bison | Final versions (ch. 7 installed only parts). |
| 8.37 Libtool, 8.38 GDBM, 8.39 Gperf, 8.40 Expat | Libraries and generators used by later packages (Expat: XML, for Python and XML::Parser). |
| 8.41 Inetutils | `ping`, `hostname`, `telnet`, `ftp`; servers and obsolete r-tools disabled; `ifconfig` to `/usr/sbin`. |
| 8.42 Less | The pager. |
| 8.43 Perl, 8.44 XML::Parser, 8.45 Intltool | Final Perl (shared, threads, system zlib/bzip2), then the Perl modules autotools-era packages need. |
| 8.46 Autoconf, 8.47 Automake | The autotools (with Libtool, 8.37): the subject requires them, and they rebuild `configure` scripts. |
| 8.48 OpenSSL | TLS and crypto: needed by Python, Kmod, and in phase 7 by wget/make-ca/ssh. |
| 8.49 Libelf | Only libelf from Elfutils: the kernel build needs it. |
| 8.50 Libffi | Lets Python call C. **Generic build** (`--without-gcc-arch`), as the book says when the system will run on another CPU. |
| 8.51 Python | Final Python 3 (shared, system Expat, profile-optimized). |
| 8.52–8.55 Flit-core, Packaging, Wheel, Setuptools | Python packaging tools, built from source and installed with `pip3 --no-index` (no download). |
| 8.56 Ninja, 8.57 Meson | The build system used by Kmod (and many modern packages). |
| 8.58 Kmod | `modprobe`, `insmod`, `lsmod`… the kernel module tools: half of the subject's "module loader" (the other half is Eudev, 8.76). Meson-only in version 34. |

### What the review fixed (8.30–8.58)

- **Ncurses:** built without the C++ binding (`--without-cxx-binding`) → `--with-cxx-shared` as in the book.
- **Perl:** `-D usethreads` was missing.
- **Inetutils:** an invented `sed` on `configure` ("if needed") replaced by the
  book's telnet fix; `--disable-telnet` and an `|| true` that hid a failing `mv` removed.
- **OpenSSL, Intltool:** version strings computed with `|| true` fallbacks that
  hid errors → the directory name.

Checked both ways against the book (every book command present, every script
line in the book): only equivalent differences left. Not done on purpose: the
ABI-5 Ncurses compatibility libraries and the Python HTML docs.

## 8.59–8.85 — the rest of the userland, boot pieces, cleanup

| Step | What and why |
|---|---|
| 8.59 Coreutils | With the book's two patches (upstream fix, i18n: multibyte text in `cut`, `sort`…). |
| 8.59a Check | Not in the 12.4 book: C unit-test framework, kept because the subject lists it. |
| 8.60 Diffutils, 8.61 Gawk, 8.62 Findutils, 8.65 Gzip, 8.69 Make, 8.70 Patch, 8.71 Tar | Final versions of the tools of ch. 6. Gawk also provides the `awk` man page. |
| 8.63 Groff | Formats man pages; paper size **A4**. |
| 8.64 GRUB | Bootloader programs only: it is installed on the disk in phase 6. |
| 8.66 IPRoute2 | `ip`: interfaces, addresses, routes. |
| 8.67 Kbd | Keymaps and console fonts (`loadkeys`); patch for the Backspace key. |
| 8.68 Libpipeline, 8.77 Man-DB | `man` and its library; no systemd files. |
| 8.72 Texinfo, 8.73 Vim | Info reader; the editor, with `vi` → `vim` and `/etc/vimrc`. |
| 8.74 MarkupSafe, 8.75 Jinja2 | Python modules (template engine) used by build tools. |
| 8.76 **Eudev** | The device manager: creates `/dev` entries and loads the modules the hardware needs, with Kmod (8.58): the subject's *kernel module loader*. Replaces the book's *Udev from Systemd*; see below. |
| 8.78 Procps-ng | `ps`, `top`, `free`, `watch`… |
| 8.79 Util-linux | `mount`, `fdisk`, `lsblk`, `swapon`…; no systemd support. |
| 8.80 E2fsprogs | ext4 tools (`mkfs.ext4`, `fsck.ext4`). `metadata_csum_seed` disabled in `mke2fs.conf`: GRUB 2.12 cannot read file systems created with it. |
| 8.81 Sysklogd | The system logger: `/var/log/{sys,kern,auth,daemon,mail,user}.log`, no network port (`secure_mode 2`). |
| 8.82 SysVinit | `init`, PID 1: reads `/etc/inittab` and runs the bootscripts (phase 6). The subject's *central management and configuration*. |
| 8.84 Stripping | Removes debugging symbols (hundreds of MB): a smaller image to carry to school. Libraries in use are stripped on a copy. |
| 8.85 Cleanup | `/tmp`, `.la` files, leftovers of the cross-toolchain. |

### Eudev instead of Udev from Systemd

The subject lists *Eudev* and the *Udev-lfs Tarball*. The 12.4 book has no Eudev
page any more, so the script follows LFS 9.1 (the last book with Eudev),
adapted to the merged `/usr` layout. Checked against the sources:

- with `--prefix=/usr`, Eudev's defaults already put rules in `/usr/lib/udev/rules.d`
  and libraries in `/usr/lib` (LFS 9.1 needed extra options for its split `/usr`);
- the 12.4 bootscripts call `/sbin/udevd` (installed by Eudev in `/usr/sbin`) and
  `/bin/udevadm` (a link to `/usr/sbin/udevadm`);
- `udev-lfs-20230818` only installs `55-lfs.rules` (set the clock when the RTC
  appears) and the persistent-network-name scripts: nothing systemd-specific;
- man pages are prebuilt in the tarball; `blkid` support comes from Util-linux.

### What the review fixed (8.59–8.85)

- **Missing patches or patches applied only "if present"** (silently skipped if the
  file were missing): Coreutils (`upstream_fix` was missing entirely), Kbd, SysVinit.
- **Invented commands** not in the book: a `sed` on Procps' `watch.c`, `./autogen.sh`
  in Sysklogd, `CFLAGS` in Coreutils.
- **Sysklogd:** mail logged to `user.log`, no `secure_mode 2`, missing options.
- **E2fsprogs:** the `metadata_csum_seed` fix (GRUB compatibility) was missing.
- **Util-linux, Man-DB:** options that keep systemd files out were missing.
- **Procps:** `--enable-watch8bit`; **Gawk:** awk man page; **Texinfo:** the book's
  `sed`; **GRUB:** `extra_deps.lst` as in the book; **Groff:** A4 (was letter).
- **Vim:** the version for the doc link could never be computed (an error hidden
  by `|| true`); `/etc/vimrc` as in the book.
- **8.84 Stripping and 8.85 Cleanup were not scripted at all**: added from the book.

Checked both ways against the book: only equivalent differences left, plus
optional documentation (HTML manuals) not installed.

Next: [Phase 6–7 — boot and network](6-7_boot_network.md).
