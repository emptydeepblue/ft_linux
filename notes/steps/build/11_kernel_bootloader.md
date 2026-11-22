# Kernel Build and Bootloader — ft_linux

> **Automated:** `scripts/03_system/03_kernel.sh` (sources in `/usr/src/kernel-$KVER`,
> `make defconfig` + [config/kernel.config](../../../config/kernel.config) via
> `merge_config.sh`, checks that every option survived and that
> `kernelrelease` = `6.16.1-everonel`) and `04_grub.sh` (`grub-install
> --target=i386-pc` on the disk holding `/boot` — the loop device when building
> on the image — plus a generated grub.cfg). Both run from
> `06_run_system_config.sh`. The manual steps below are kept as explanation.

## Subject requirements (checklist)

- [ ] Kernel version >= 4.0
- [ ] Kernel version string contains student login: `Linux kernel X.Y.Z-everonel`
- [ ] Sources in `/usr/src/kernel-$(version)`
- [ ] Binary in `/boot` named `vmlinuz-<linux_version>-everonel`
- [ ] Bootloader (GRUB) installed and configured to that kernel name
- [ ] 3 partitions: root (`/dev/sda2`), `/boot` (`/dev/sda1`), swap (`/dev/sda3`)

---

## Step 1 — Download and place kernel sources

Run **outside the chroot** as `linuxdev`:

```bash
# download — use the latest stable 6.x or any >= 4.0
KVER=6.16.1
wget -P /mnt/lfs/sources \
  https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.16.1.tar.xz
```

Inside the chroot:

```bash
KVER=6.16.1
mkdir -pv /usr/src
cd /sources && tar -xf linux-${KVER}.tar.xz
cp -r linux-${KVER} /usr/src/kernel-${KVER}
cd /usr/src/kernel-${KVER}
make mrproper
```

---

## Step 2 — Configure the kernel

```bash
cd /usr/src/kernel-$(ls /usr/src/ | grep kernel- | head -1 | sed 's/kernel-//')
make defconfig
make menuconfig
```

**Mandatory settings in menuconfig** (subject requirements):

| Location | Setting | Value |
|---|---|---|
| General setup → Local version | `CONFIG_LOCALVERSION` | `-everonel` |
| General setup → Default hostname | `CONFIG_DEFAULT_HOSTNAME` | `everonel` |
| General setup | `CONFIG_LOCALVERSION_AUTO` | **disabled** |
| Enable loadable module support | `CONFIG_MODULES` | **enabled** |

**VirtualBox/QEMU required drivers** (enable as built-in `[*]`, not modules):

| Location | Setting |
|---|---|
| Device Drivers → SCSI → SCSI disk support | `CONFIG_BLK_DEV_SD=y` |
| Device Drivers → Serial ATA → AHCI | `CONFIG_SATA_AHCI=y` |
| Device Drivers → Serial ATA → PIIX | `CONFIG_ATA_PIIX=y` |
| Device Drivers → Network → Intel E1000 | `CONFIG_E1000=y` |
| File systems → Ext4 | `CONFIG_EXT4_FS=y` |
| File systems → /proc | `CONFIG_PROC_FS=y` |
| Device Drivers → Generic driver → devtmpfs | `CONFIG_DEVTMPFS=y`, `CONFIG_DEVTMPFS_MOUNT=y` |

> If any of these are modules (`M`) instead of built-in (`*`), the system will
> not boot — they are needed before modules can be loaded.

---

## Step 3 — Build and install

```bash
cd /usr/src/kernel-$(ls /usr/src/ | grep kernel- | head -1 | sed 's/kernel-//')
KVER=$(make kernelrelease)   # e.g. "6.16.1-everonel"

make -j$(nproc)
make modules_install          # installs to /lib/modules/${KVER}/

# install kernel binary — subject naming requirement
cp -v arch/x86/boot/bzImage /boot/vmlinuz-${KVER}
cp -v System.map /boot/System.map-${KVER}
cp -v .config /boot/config-${KVER}
```

Verify:
```bash
ls -lh /boot/vmlinuz-*        # should show vmlinuz-6.16.1-everonel
uname -r 2>/dev/null || true  # won't show new version until reboot
```

---

## Step 4 — Install GRUB

```bash
# install GRUB to the MBR of the first disk
grub-install --target=i386-pc /dev/sda

# create /boot/grub directory if missing
mkdir -pv /boot/grub
```

Create `/boot/grub/grub.cfg` — adapt `KVER` to match what `make kernelrelease` returned:

```bash
KVER=6.16.1-everonel    # replace with actual value

cat > /boot/grub/grub.cfg << EOF
set default=0
set timeout=5

menuentry "ft_linux ${KVER}" {
    set root='hd0,msdos1'
    linux   /vmlinuz-${KVER} root=/dev/sda2 ro
}

menuentry "ft_linux ${KVER} (single user)" {
    set root='hd0,msdos1'
    linux   /vmlinuz-${KVER} root=/dev/sda2 ro single
}
EOF
```

> `hd0,msdos1` = first disk, first partition (MBR layout).
> For GPT disks use `gpt1` instead of `msdos1`.
> Verify partition layout with `fdisk -l /dev/sda` before writing grub.cfg.

---

## Step 5 — Verify before reboot

```bash
# kernel binary is named correctly
ls /boot/vmlinuz-*-everonel

# sources are in the right place
ls /usr/src/kernel-*/Makefile

# modules installed
ls /lib/modules/

# GRUB config references the right kernel name
grep linux /boot/grub/grub.cfg

# fstab is sane
cat /etc/fstab

# hostname is set
cat /etc/hostname
```

---

## Step 6 — Exit chroot and unmount

Run **outside the chroot** as `linuxdev`:

```bash
# exit the chroot first (type 'exit' or Ctrl+D inside chroot)

# unmount virtual filesystems
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

# unmount LFS partitions
umount -v $LFS/boot
umount -v $LFS
# if swap was activated: swapoff /dev/sda3
```

Then shut down the VM and boot from the LFS disk.

---

## Step 7 — Generate checksum (submission)

Run on the **host** after the VM is shut down:

```bash
# VirtualBox
shasum < ~/VirtualBox\ VMs/ft_linux/ft_linux.vdi > ~/42/RNCP7/ft_linux/checksum.txt

# or with md5sum
md5sum ~/VirtualBox\ VMs/ft_linux/ft_linux.vdi > ~/42/RNCP7/ft_linux/checksum.txt
```

Commit the checksum to the repo:

```bash
cd ~/42/RNCP7/ft_linux
git add checksum.txt
git commit -m "Add disk image checksum for evaluation"
git push
```

---

## Troubleshooting

### Kernel panics at boot: `VFS: Unable to mount root fs`

Root filesystem driver is a module, not built-in.  
**Fix:** Rebuild with `CONFIG_EXT4_FS=y` and `CONFIG_SATA_AHCI=y` / `CONFIG_ATA_PIIX=y` as `[*]` (built-in), not `[M]`.

### GRUB: `error: unknown filesystem`

GRUB can't read the `/boot` partition.  
**Fix:** Confirm `/boot` is ext4 (not ext2/3) and that `grub-install` targeted the correct disk (`/dev/sda`, not a partition like `/dev/sda1`).

### `make kernelrelease` doesn't include `-everonel`

`CONFIG_LOCALVERSION` is not set or `CONFIG_LOCALVERSION_AUTO=y` is overriding it.  
**Fix:** In `.config`, set `CONFIG_LOCALVERSION="-everonel"` and `CONFIG_LOCALVERSION_AUTO=n`, then rebuild.

### Network not coming up after boot

Interface name may differ from `eth0` (e.g. `enp0s3` with predictable names).  
**Fix:** Check `ip link` after boot, rename the sysconfig file to match:
```bash
mv /etc/sysconfig/ifconfig.eth0 /etc/sysconfig/ifconfig.enp0s3
# edit the file and update IFACE=enp0s3
```
Or disable predictable interface names by adding `net.ifnames=0` to the kernel command line in `grub.cfg`.
