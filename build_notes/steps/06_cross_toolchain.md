# Compiling a cross toolchain for ft_linux

## Introduction
This document provides instructions on how to compile a cross toolchain for ft_linux. A cross toolchain allows you to build software for a different target architecture than the one you are building on.

## Prerequisites
Before you begin, ensure you have all the necessary .tar.gz files for the components of the toolchain, such as binutils, gcc, and glibc. You will also need to have the appropriate development tools installed on your host system.

## Fast Setup
- [Check env](../../scripts/02_build/01_check_env.sh)
- [Cross toolchain build](../../scripts/02_build/02_cross_toolchain.sh)
    - [Binutils](../../scripts/02_build/cross-toolchain/01_binutils.sh)
    - [GCC](../../scripts/02_build/cross-toolchain/02_gcc.sh)
    - [Linux API](../../scripts/02_build/cross-toolchain/03_linux_api.sh)
    - [Glibc](../../scripts/02_build/cross-toolchain/04_glibc.sh)
    - [Libstdc](../../scripts/02_build/cross-toolchain/05_libstdc.sh)

```bash
bash scripts/01_check_env.sh
# Run the toolchain scripts wrapper
bash scripts/02_run_toolchain.sh
# bash scripts/run_toolchain.sh <n> to restart at step `n`
```

## Manual Setup

### Step 1: Extract the Source Files
Start by extracting the source files for each component of the toolchain. You can use the following commands to extract the .tar.gz files:
```bash
cd /path/to/your/source/files
tar -xzf <tool>-<version>.tar.gz
cd <tool>-<version>
```
### Step 2: Configure environment for tool
Next, you need to configure and build binutils for the target architecture. Use the following commands:
```bash
mkdir build-<tool> && cd build-<tool>
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT
```
### Step 3: Build and Install tools
After configuring binutils, you can build and install it using the following commands:
```bash
make
make install
```
### Step 4: Get back and clean up
After installing binutils, navigate back to the source directory and clean up the build directory:
```bash
cd $LFS/sources
rm -rf build-<tool>
```

## Compilation orders
The general order of compilation for the components of the toolchain is as follows:

### Cross-Toolchain
These create the cross-compiler that targets `$LFS`:

| # | Package | Notes |
|---|---------|-------|
| 1 | **Binutils** (Pass 1) | Assembler/linker needed by GCC |
| 2 | **GCC** (Pass 1) | Cross-compiler (C/C++ only), bundles GMP, MPFR, MPC |
| 3 | **Linux API Headers** | Kernel headers for Glibc to compile against |
| 4 | **Glibc** | C library — **run the sanity check after this!** |
| 5 | **Libstdc++** (from GCC tree) | C++ standard library (Pass 1) |

### Installing Pattern
The first 5 packages are cross-compiled with `--host=$LFS_TGT` and installed to `$LFS/tools`. 
The installation foolows the same pattern for each package:
1. Extract the source
2. Cd into the source directory
3. Configure with the appropriate directories and flags (e.g., `--host=$LFS_TGT`, `--prefix=$LFS/tools`, etc.)
3. Make
4. Make install
5. Cd back to sources
6. Clean up the source directory (optional but recommended to save space)
After that, the toolchain is complete and you can use it to build the rest of the system natively in chroot.

### Cross-Compiling Temporary Tools
These are cross-compiled with `--host=$LFS_TGT` and installed to `$LFS`:

| # | Package | Notes |
|---|---------|-------|
| 6 | **M4** | Macro processor, needed by Bison/Flex |
| 7 | **Ncurses** | Terminal library, needed by Bash/others |
| 8 | **Bash** | Shell for chroot |
| 9 | **Coreutils** | ls, cp, mv, etc. |
| 10 | **Diffutils** | diff, cmp |
| 11 | **File** | File type detection |
| 12 | **Findutils** | find, xargs |
| 13 | **Gawk** | AWK implementation |
| 14 | **Grep** | Pattern matching |
| 15 | **Gzip** | Compression |
| 16 | **Make** | Build automation |
| 17 | **Patch** | Apply patches |
| 18 | **Sed** | Stream editor |
| 19 | **Tar** | Archive tool |
| 20 | **Xz** | Compression |
| 21 | **Binutils** (Pass 2) | Rebuilt for the target |
| 22 | **GCC** (Pass 2) | Full cross-compiler, bundles GMP, MPFR, MPC |

## Entering Chroot & Additional Temp Tools (as root in chroot)
After chrooting into `$LFS`, build these **natively** inside the chroot:

| # | Package | Notes |
|---|---------|-------|
| 23 | **Gettext** | Internationalization (only temp tools portion) |
| 24 | **Bison** | Parser generator |
| 25 | **Perl** | Needed by Autoconf/Automake/Texinfo |
| 26 | **Python** (temporary) | Needed by some build systems — **wait**, you removed Python... |
| 27 | **Texinfo** | Info documentation system |
| 28 | **Util-linux** | Mount, fdisk, etc. |

> ⚠️ **About Python**: You marked it `[-]` but the LFS Ch. 7 temporary tools and several Ch. 8 packages (e.g., `wheel` for Perl test suites, some configure scripts) may need it. Double-check if your LFS book version requires a temporary Python build here. If it does, you'll need to download it back.

## Then Chapter 8 — Final System (in chroot)
All remaining packages from your list get built **in dependency order** inside chroot. That's ~60+ packages — the LFS book gives the exact order. The key is: **follow the book's chapter 8 order exactly**, don't reorder.
