# Phase 8 — From the raw image to the evaluation disk

**Folder:** [`build/8_release/`](../../build/8_release/) · **Who/where:** on the host,
after the chroot is exited · **Status:** written, not run yet

The build produced `/var/lib/ft_linux/ft_linux.img`, a raw disk image. This
phase checks that it boots on hardware like the school VM's, makes it small,
and turns it into the file that is evaluated: `ft_linux.vdi` and its checksum.

```bash
exit                                                   # leave the chroot
sudo bash build/lfs_disk.sh detach
bash build/8_release/01_boot_test.sh                   # no sudo
sudo bash build/lfs_disk.sh mount
sudo bash build/8_release/02_prepare_image.sh
sudo bash build/lfs_disk.sh detach
sudo bash build/8_release/03_make_vdi.sh
```

## Steps

| Script | Who | What and why |
|---|---|---|
| `01_boot_test.sh` | user (group kvm) | Boots the image in QEMU with the school VM's hardware: BIOS, SATA/AHCI, e1000 + NAT, ssh on `127.0.0.1:2222`, UTC clock. **`-snapshot`**: the image is not modified. **`-cpu qemu64`**: a plain x86-64 CPU instead of this PC's, so anything built for the build machine's CPU fails here (*Illegal instruction*), not at school. Then run `ft_check` inside. |
| `02_prepare_image.sh` | root | Copies the build logs into the repo (`logs/`, git-ignored); removes `/sources`; `make clean` in `/usr/src/kernel-6.16.1` (sources and `.config` stay, as the subject wants; object files go); empties `/tmp`; fills the free space with zeros and deletes it. Asks for confirmation. |
| `03_make_vdi.sh` | root | `qemu-img convert` → `ft_linux.vdi` (dynamic). Zero blocks are not written, so the file is already compact. Writes **`checksum.txt`** with the subject's command (`shasum < ft_linux.vdi`) and a compressed copy `ft_linux.vdi.xz` for the GitHub Release. |

## The checksum must stay valid

Booting a `.vdi` attached normally changes it, and the checksum with it. So
after `03_make_vdi.sh` the file is only ever attached **immutable** — which
[`eval/02_create_vm.sh`](../../eval/02_create_vm.sh) does — at home and at school.

## Final test in VirtualBox (Windows, at home)

The same script as at school, with Windows' VirtualBox called from WSL. Copy
the file to a Windows disk first: VirtualBox handles `\\wsl.localhost\…` paths
badly. The copy is identical, so is its checksum.

```bash
mkdir -p /mnt/c/ft_linux && cp /var/lib/ft_linux/ft_linux.vdi /mnt/c/ft_linux/
export VBOXMANAGE="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
bash eval/01_verify.sh /mnt/c/ft_linux/ft_linux.vdi
bash eval/02_create_vm.sh /mnt/c/ft_linux/ft_linux.vdi --start
# … ssh in, ft_check, the download demo …
bash eval/02_create_vm.sh --remove
bash eval/01_verify.sh /mnt/c/ft_linux/ft_linux.vdi        # same hash
```

Then commit `checksum.txt` and upload `ft_linux.vdi.xz` as a Release asset.
