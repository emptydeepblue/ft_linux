# LFS VM Setup
This document provides instructions for setting up a virtual machine (VM) for Linux From Scratch (LFS) development. The VM will be configured with the necessary tools and environment to facilitate the LFS build process.

--- 
*Table of Contents*  
[Prerequisites](#prerequisites)  
[Step 1: Create a New Virtual Machine](#step-1-create-a-new-virtual-machine)  
[Step 2: Install the Operating System](#step-2-install-the-operating-system)  
[Step 3: Configure the VM for LFS Development](#step-3-configure-the-vm-for-lfs-development)  
[Step 4: Prepare the LFS build environment](#step-4-prepare-the-lfs-build-environment)  
[Step 5: Download LFS sources](#step-5-download-lfs-sources)  
[Step 6: Finalize the setup](#step-6-finalize-the-setup)  

## Prerequisites
- A virtualization software (e.g., VirtualBox, VMware)
- An ISO image of a Linux distribution (e.g., Ubuntu, Debian) to install as the host operating system
- Sufficient hardware resources (4 CPU cores, 8 GB RAM, 60 GB disk space) to run the VM smoothly  

## Step 1: Create a New Virtual Machine
> ⚠️ Remember to deactivate the `Skip unattended installation` or similar options, as we need to perform a manual partitioning of the operating system.
1. Open your virtualization software and create a new virtual machine.
2. Choose a name for your VM (e.g., "LFS Build Environment").
3. Select the type and version of the operating system you will be installing (e.g., Linux, Ubuntu server).
4. Allocate at least 4 CPU cores and 8 GB of RAM to the VM.
5. Create a virtual hard disk with at least 60 GB of storage.
6. Attach the ISO image of the Linux distribution to the VM's virtual CD/DVD drive.

## Step 2: Install the Operating System
1. Start the VM and follow the on-screen instructions to install the operating system.
2. During the installation process
    - choose manual partitioning to create the necessary partitions for the LFS build environment. A recommended partition scheme is:
        - `/boot` partition: 1 GB
        - `swap` partition: 2 GB
        - `/` (root) partition: ~57 GB
    - set your intra username as VM hostname and create a user account for LFS development (e.g., "lfsuser").
3. Complete the installation and reboot the VM.
4. In VM settings, select the newly created VM and configure the network settings to use a NAT.

## Step 3: Configure the VM for LFS Development
2. Update the package manager and install necessary development tools: 
    ```bash
    sudo apt update
    sudo apt install -y git openssh-server
    ```
   > ⚠️ If the package manager is not working due to DNS issues, refer to the [DNS issues on host distribution](issues.md#1-dns-issues-on-host-distribution-ubuntu-server-2204) troubleshooting steps.
3. Configure git ssh keys for accessing the LFS repository (if needed):
    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```
4. Check the services status:
    ```bash
    sudo systemctl status git
    sudo systemctl status ssh
    ```
## Step 4: Prepare the LFS build environment
1. Create the LFS directory and set environment variables:
    ```bash
    export LFS=/mnt/lfs
    sudo mkdir -pv $LFS
    sudo mkdir -pv $LFS/tools
    sudo mkdir -pv $LFS/sources
    sudo chmod -v a+wt $LFS/sources # Make sources directory writable for all users
    ```
2. Optional: If already using separate partitions for LFS (recommended for final system), mount them (adjust device names as needed):
    ```bash
    sudo mount -v -t ext4 /dev/sdb1 $LFS
    sudo mount -v -t ext4 /dev/sdb2 $LFS/boot
    sudo /sbin/swapon -v /dev/sdb3
    ```
    > ⚠️ It is recommended to use separate partitions for the LFS build environment. If you didn't set up separate partitions, you can add a second virtual disk later and mount it to `/mnt/lfs`.
3. Create the LFS user and set ownership:
    ```bash
    sudo groupadd lfs
    sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    sudo passwd lfs
    sudo chown -v lfs $LFS/tools    # Set ownership of tools directory to LFS user
    sudo chown -v lfs $LFS/sources  # Set ownership of sources directory to LFS user
    ```
4. Switch to the LFS user and set up the build environment:
    ```bash
    su - lfs
    ```
5. Set up the `lfs` user's .bash_profile   
    🔍 **Explanation of the .bash_profile content:**
    - The `exec env -i` command starts a new shell with a clean environment, ensuring that no inherited environment variables from the host system interfere with the LFS build process.
    - The `HOME=$HOME` variable ensures that the HOME environment variable is set correctly for the LFS user, allowing access to the user's home directory and configuration files.
    - The `TERM=$TERM` variable preserves the terminal type, which is important for proper display and functionality of the terminal during the build process.
    - The `PS1='\u:\w\$ '` sets a simple prompt that shows the username and current working directory, which can be helpful for keeping track of where you are in the filesystem during the build process.
    ```bash
    cat > ~/.bash_profile << "EOF"
    >exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
    >EOF
    ```
6. Set up the `lfs` user's .bashrc with the necessary environment variables for the LFS build:
    🔍 **Explanation of the environment variables:**
    - The `set +h` command disables bash's hash function, which can cause issues during the LFS build process when new tools are created and need to be found in the PATH.  
    - The `umask 022` command sets the default permissions for newly created files and directories to be readable by everyone but only writable by the owner, which is important for security and proper access control during the build process.  
    - The `LFS` variable points to the mount point of the LFS partition, which is where the LFS system will be built.  
    - The `LC_ALL=POSIX` setting ensures that the build process uses a consistent locale, which can help avoid issues with character encoding and sorting.  
    - The `LFS_TGT` variable defines the target triplet for cross-compilation, which is used to specify the architecture and system type for the tools being built.  
    - By prepending `/tools/bin` to the `PATH`, we ensure that the temporary tools created during the build process are used instead of any existing tools on the host system, which is crucial for a successful LFS build.  
    ```bash
    cat > ~/.bashrc << "EOF"
    >set +h
    >umask 022
    >LFS=/mnt/lfs
    >LC_ALL=POSIX
    >LFS_TGT=$(uname -m)-lfs-linux-gnu
    >PATH=/tools/bin:/bin:/usr/bin
    >export LFS LC_ALL LFS_TGT PATH
    >EOF
    ```
7. Load the new environment variables:
    ```bash
    source ~/.bash_profile
    ```
## Step 5: Download LFS sources:
🔍 The **wget-list** contains the URLs of all the source packages and patches needed for the LFS build like binutils (binary tools as assembler, linker, etc.), gcc (GNU Compiler Collection C, C++, etc.), glibc (GNU core C libraries), etc.  
It was created by the LFS maintainers to simplify the process of downloading all necessary files.  
By using wget with the `--input-file` option, you can automate the download of all required sources in one command. The `--continue` option allows you to resume downloads if they are interrupted, which is especially useful for large files or slow internet connections.

1. Download the wget list and sources:
    ```bash
    cd $LFS/sources
    wget http://www.linuxfromscratch.org/lfs/view/stable/wget-list
    wget --input-file=wget-list --continue --directory-prefix=$LFS/sources 2>&1 | tee wget_errors.log
    ```
    > ⚠️ If some files failed to download refer to the [Package Download Failures](issues.md#2-package-download-failures) troubleshooting steps.
2. Verify the downloaded files (optional but recommended):
    ```bash
    wget https://www.linuxfromscratch.org/lfs/downloads/12.4/md5sums -P $LFS/sources
    md5sum -c md5sums 2>&1 | tee md5_verification.log
    ```
    > ⚠️ If any files fail the checksum verification refer to the [Package Download Failures](issues.md#2-package-download-failures) troubleshooting steps.
3. Once all files are downloaded and verified, you can optionally remove the `wget-list`, `md5sums`, and commands outputs files to save space:
    ```bash
    sudo rm -f wget-list md5sums wget_errors.log md5_verification.log
    ```

## Step 6: Finalize the setup
1. Ensure that the LFS user has the necessary permissions to access the sources and tools directories:
    ```bash
    sudo chown -R lfs:lfs $LFS/sources
    sudo chown -R lfs:lfs $LFS/tools
    ```
2. The LFS build environment is now set up and ready for the next steps in the LFS build process.
> ⚠️ It is recommended to take a snapshot of the VM at this point, so you can easily revert to this clean state if needed during the LFS build process.

> Note: From the instruction in the LFS book I skipped:
1. the step of creating a separate partition for the LFS build environment, as it is not strictly required and can be done later if desired. However, it is recommended to use separate partitions for better organization and performance during the build process.
2. Creating part of the directory structure for the LFS system (e.g. etc, var, usr, bibn.) as it will be done later during the actual build process when the LFS system is being constructed. At this stage, we are only preparing the build environment and downloading the necessary sources. (4.2 in the LFS book)
3. Missing some of the environment variables that are not strictly necessary for the initial setup, but will be set later during the build process when they are needed. For example, `MAKEFLAGS` can be set later to optimize the build process once we have a better understanding of the system's resources and requirements. (4.4 in the LFS book)
