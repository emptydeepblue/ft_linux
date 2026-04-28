# 01 VM Setup

This chapter covers creating a VirtualBox VM, installing the host OS, adding the second disk for LFS, and installing the required build tools.

---

*Table of Contents*
- [Prerequisites](#prerequisites)
- [Step 1: Create the Virtual Machine](#step-1-create-the-virtual-machine)
- [Step 2: Install the Host Operating System](#step-2-install-the-host-operating-system)
- [Step 3: Add a Second Virtual Disk for LFS](#step-3-add-a-second-virtual-disk-for-lfs)
- [Step 4: Install Required Build Tools](#step-4-install-required-build-tools)

---

## Prerequisites

- VirtualBox installed on your host machine
- An ISO image of a Linux distribution (e.g., Ubuntu Server 22.04)
- Sufficient hardware resources:
    - 4 CPU cores (minimum)
    - 8 GB RAM (minimum)

---

## Step 1: Create the Virtual Machine

1. Open VirtualBox and click **New**.
2. Enter a name (e.g., `ft_linux`), and attach your ISO.
3. Set:
   - **Hostname**: your intra username (e.g., `everonel`)
   - **User account**: your intra username
4. Allocate at least **4 CPUs** and **8 GB of RAM**.
5. Create a new virtual hard disk: **VDI → Dynamically allocated → 30 GB**.
6. Finish and start the VM.

---

## Step 2: Set up network
1. Shutdown the VM
2. In VirtualBox go to **Settings → Network → Adapter 1 → NAT**.
3. Click **Advanced → Port Forwarding** and add:
    - Protocol: TCP | Host Port: `2222` | Guest Port: `22`
    - This allows SSH from your host via `ssh user@localhost -p 2222`.

---

## Step 3: Add a Second Virtual Disk for LFS

The LFS system will be built on a separate disk so it never touches the host OS.

1. Go to **Settings → Storage → Controller: SATA**.
2. Click the **Add Hard Disk** icon (disk with `+`) → **Create New Disk**.
3. Choose **VDI → Dynamically allocated → 30 GB** and confirm.
4. Start the VM and log in.
5. Verify the new disk is visible:
   ```bash
   lsblk
   ```
   Expected:
   ```
   sda    30G   ← Host OS
   ├─sda1 ...
   └─sda2 ...
   sdb    30G   ← NEW empty disk for LFS
   ```
   > The device name may differ (e.g., `/dev/sdc`). All subsequent steps use `/dev/sdb` — adjust if yours is different.

---

## Step 4: Install Required Build Tools

```bash
sudo apt update
sudo apt install -y build-essential bison gawk m4 texinfo wget curl git openssh-server
```

> If `apt` fails due to DNS issues, see the [DNS troubleshooting](../issues.md#1-dns-issues-on-host-distribution-ubuntu-server-2204) section.

Run the version-check script to confirm all required host tools are present:

```bash
bash scripts/01_setup/00_version_check.sh
```

All tools must report a version. Fix any missing ones before proceeding.
[sh is not bash](../notes/issues.md#2-sh-is-not-bash)

---

**Next:** [02 Disk Partitioning](02_disk_paritioning.md)
