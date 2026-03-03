# 01 VM Setup
This document provides instructions for setting up a virtual machine (VM) for Linux From Scratch (LFS) development. The VM will be configured with the necessary tools and environment to facilitate the LFS build process.

--- 
*Table of Contents*  
[Prerequisites](#prerequisites)  
[Step 1: Create a New Virtual Machine](#step-1-create-a-new-virtual-machine)  
[Step 2: Install the Host Operating System](#step-2-install-the-host-operating-system)  
[Step 3: Add a Second Virtual Disk for LFS](#step-3-add-a-second-virtual-disk-for-lfs)  
[Step 4: Configure the VM for LFS Development](#step-4-configure-the-vm-for-lfs-development)  
[Step 5: Partition and Mount the LFS Disk](#step-5-partition-and-mount-the-lfs-disk)  
[Step 6: Prepare the LFS Build Environment](#step-6-prepare-the-lfs-build-environment)  
[Step 7: Create the LFS User](#step-7-create-the-lfs-user)  
[Step 8: Create the Directory Layout for Cross-Compilation](#step-8-create-the-directory-layout-for-cross-compilation)  
[Step 9: Download LFS Sources](#step-9-download-lfs-sources)  
[Step 10: Finalize the Setup](#step-10-finalize-the-setup)  

---

## Prerequisites
- A virtualization software (e.g., VirtualBox, VMware)
- An ISO image of a Linux distribution (e.g., Ubuntu Server 22.04) to install as the host operating system
- Sufficient hardware resources:
    - 4 CPU cores (minimum)
    - 8 GB RAM (minimum)
    - **Two virtual disks**: ~30 GB for the host OS, ~30 GB for the LFS system

---

## Step 1: Create a New Virtual Machine
> ⚠️ Remember to deactivate `Skip unattended installation` or similar options, as we need to perform manual partitioning of the host operating system.
1. Open your virtualization software and create a new virtual machine.
2. Choose a name for your VM (e.g., "LFS Build Environment").
3. Select the type and version of the operating system you will be installing (e.g., Linux, Ubuntu 64-bit).
4. Allocate at least **4 CPU cores** and **8 GB of RAM** to the VM.
5. Create the first virtual hard disk with **~30 GB** of storage (for the host OS).
6. Attach the ISO image of the Linux distribution to the VM's virtual CD/DVD drive.
7. Configure the network settings to use **NAT** (for internet access during setup and source downloads).

---

## Step 2: Install the Host Operating System
> The host OS is just a build tool — it's used to compile the LFS system. The LFS system itself lives on a separate disk.

1. Start the VM and follow the on-screen instructions to install the operating system.
2. During installation:
    - Use **guided partitioning** (use entire disk) for the host — we don't need manual partitioning here since the host disk is only for Ubuntu.
    - Set your **intra username** as the VM hostname (e.g., `everonel`).
    - Create a user account (e.g., `everonel`).
    - Enable **OpenSSH server** if offered during install (useful for remote access).
3. Complete the installation and reboot the VM.
4. Remove the ISO from the virtual CD/DVD drive to prevent booting from it again.

---

## Step 3: Add a Second Virtual Disk for LFS
> ⚠️ This is **mandatory**. The LFS system needs its own dedicated disk with separate /boot, swap, and root partitions. This is a requirement of the ft_linux subject.

### VirtualBox:
1. **Shut down** the VM.
2. Go to **Settings → Storage → Controller: SATA**.
3. Click the **"Add Hard Disk"** icon (disk with a `+`).
4. Choose **Create New Disk** → VDI → Dynamically allocated → **30 GB**.
5. Start the VM.

### VMware:
1. **Shut down** the VM.
2. Go to **VM Settings → Add → Hard Disk → Create a new virtual disk**.
3. Set size to **30 GB**, store as a single file.
4. Start the VM.

### Verify the new disk is visible:
```bash
lsblk
```
Expected output:
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   30G  0 disk              ← Host OS
├─sda1   ...
├─sda2   ...
└─sda3   ...
sdb      8:16   0   30G  0 disk              ← NEW empty disk for LFS
```
> ⚠️ The device name may differ (e.g., `/dev/sdc`). Use `lsblk` to identify the correct empty disk. All subsequent commands use `/dev/sdb` — **adjust if your disk name is different**.

---

## Step 4: Configure the VM for LFS Development

1. Log in as your regular user (e.g., `everonel`).

2. Update the package manager and install necessary development tools:
    ```bash
    sudo apt update
    sudo apt install -y build-essential bison gawk m4 texinfo
    ```
    > ⚠️ If the package manager is not working due to DNS issues, refer to the [DNS issues on host distribution](issues.md#1-dns-issues-on-host-distribution-ubuntu-server-2204) troubleshooting steps.

3. Optional: install SSH and git for remote access and version control:
    ```bash
    sudo apt install -y git openssh-server
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```

4. Run the LFS version-check script to verify host tools:
    ```bash
    bash scripts/version-check.sh
    ```
    > All tools must report a version. Fix any missing tools before proceeding.

### 10.2 Take a VM snapshot

> ⚠️ **Strongly recommended.** Take a snapshot now so you can revert to this clean state if anything goes wrong during the build.

In VirtualBox: **Machine → Take Snapshot** (name it "Pre-Chapter5-Ready")

