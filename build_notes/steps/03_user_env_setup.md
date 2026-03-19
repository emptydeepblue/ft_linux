# 03 LFS Environment Setup

This chapter covers setting up the LFS build environment, including creating a dedicated user, preparing the source and tools directories, and configuring the environment variables needed for building the toolchain.

*Table of Contents:*
- [Step 1: Prepare the LFS Build Environment](#step-1-prepare-the-lfs-build-environment)
- [Step 2: Create the LFS User](#step-2-create-the-lfs-user)
- [Step 3: Create the Directory Layout](#step-3-create-the-directory-layout)

*Scripts*
- [LFS environment setup](../../scripts/setup/02_env_setup.sh)

```bash
sudo bash scripts/setup/02_env_setup.sh
# Verify host tools
sudo su - lfs
bash scripts/version-check.sh
```

## Step 1: Prepare the LFS Build Environment

### 1.1 Create the sources and tools directories

```bash
export LFS=/mnt/lfs

sudo mkdir -pv $LFS/sources
sudo chmod -v a+wt $LFS/sources

sudo mkdir -pv $LFS/tools
```

---

## Step 2: Create the LFS User

> The `lfs` user is used to build the cross-toolchain (Chapters 5–6) without root privileges, preventing accidental damage to the host system.

### 2.1 Create the user

```bash
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
sudo passwd lfs
```

### 2.2 Set ownership

```bash
export LFS=/mnt/lfs

sudo chown -v lfs $LFS/tools
sudo chown -v lfs $LFS/sources
```

### 2.3 Switch to the lfs user

```bash
sudo su - lfs
```

### 2.4 Set up `.bash_profile`

🔍 **Explanation:** `exec env -i` starts a completely clean shell so no inherited host environment variables can interfere with cross-compilation.

```bash
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
```

### 2.5 Set up `.bashrc`

🔍 **Explanation of environment variables:**
- `set +h` — disables bash's hash function so newly built tools are always found via PATH lookup
- `umask 022` — new files are readable by everyone, writable only by owner
- `LFS` — mount point of the LFS partition
- `LC_ALL=POSIX` — consistent locale to avoid encoding issues
- `LFS_TGT` — target triplet for cross-compilation (e.g., `x86_64-lfs-linux-gnu`)
- `PATH` — `$LFS/tools/bin` first so cross-compiled tools take precedence; `/usr/bin` and `/bin` for host tools
- `CONFIG_SITE` — default options for configure scripts
- `MAKEFLAGS` — parallel compilation using all CPU cores

```bash
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=$LFS/tools/bin:/usr/bin:/bin
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS=-j$(nproc)
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF
```

### 2.6 Load the environment

```bash
source ~/.bash_profile
```

### 2.7 Verify

```bash
echo $LFS        # /mnt/lfs
echo $LFS_TGT    # x86_64-lfs-linux-gnu
echo $PATH       # /mnt/lfs/tools/bin:/usr/bin:/bin
which make       # /usr/bin/make
which gcc        # /usr/bin/gcc
```

## Step 3: Create the Directory Layout

### 3.1 Run as your regular user (exit `lfs` first):

```bash
exit  # back to everonel
export LFS=/mnt/lfs

sudo mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

# Create unified directory symlinks (bin, lib, sbin -> usr/*)
for i in bin lib sbin; do
    sudo ln -sv usr/$i $LFS/$i
done

# On x86_64, create lib64
case $(uname -m) in
    x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac

# Set ownership so lfs user can write during Chapters 5-6
sudo chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools,sources,boot}
case $(uname -m) in
    x86_64) sudo chown -v lfs $LFS/lib64 ;;
esac
```

### 3.2 Verify:
```bash
ls -la $LFS/
```
Expected:
```
bin -> usr/bin
boot/
etc/
lib -> usr/lib
lib64/
sbin -> usr/sbin
sources/
tools/
usr/
var/
```