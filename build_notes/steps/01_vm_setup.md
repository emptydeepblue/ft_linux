# 01 VM Setup

This first chapter provides instructions for setting up the virtual machine (VM) for Linux From Scratch (LFS) development. It covers creating a new VM, installing the host operating system, adding a second virtual disk for the LFS system, and configuring the VM for development.

--- 
*Table of Contents*  
[Prerequisites](#prerequisites)  
[Step 1: Create a New Virtual Machine](#step-1-create-a-new-virtual-machine)  
[Step 2: Install the Host Operating System](#step-2-install-the-host-operating-system)  
[Step 3: Add a Second Virtual Disk for LFS](#step-3-add-a-second-virtual-disk-for-lfs)  
[Step 4: Configure the VM for LFS Development](#step-4-configure-the-vm-for-lfs-development)  

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

1. Open your virtualization software and create a new virtual machine.
2. Choose a name for your VM (e.g., "LFS Build Environment").
3. Attach the ISO image of the Linux distribution to the VM's virtual CD/DVD drive.
    - Set your **intra username** as the VM hostname (e.g., `everonel`).
    - Create a user account (e.g., `everonel`).
4. Allocate at least **4 CPU cores** and **8 GB of RAM** to the VM.
5. Create the first virtual hard disk with **~30 GB** of storage (for the host OS).
1. Start the VM and install the operating system (Enable **OpenSSH server** if offered during install).
6. Complete the installation and shut down the VM.
7. In the VM settings, configure the network settings to use **NAT** 
    - enable **port forwarding** for SSH (e.g., forward host port 2222 to guest port 22) for remote access.
4. Remove the ISO from the virtual CD/DVD drive to prevent booting from it again.

---

## Step 3: Add a Second Virtual Disk for LFS

### 3.1 VirtualBox:
1. **Shut down** the VM.
2. Go to **Settings → Storage → Controller: SATA**.
3. Click the **"Add Hard Disk"** icon (disk with a `+`).
4. Choose **Create New Disk** → VDI → Dynamically allocated → **30 GB**.
5. Start the VM.

### 3.2 Verify the new disk is visible:
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
3. Install SSH and git for remote access and version control (optional):
    ```bash
    sudo apt install -y git openssh-server
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```
4. Run the LFS version-check script to verify host tools:
    ```bash
    bash scripts/version-check.sh
    ```
    > All tools must report a version. Fix any missing tools before proceeding.

GOTO [02 Partitioning and Formatting](02_partitioning.md) to prepare the new disk for LFS.