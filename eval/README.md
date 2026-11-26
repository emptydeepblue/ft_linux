# Evaluation — running ft_linux on a school PC

Everything here runs **without sudo** on the evaluation PC (Ubuntu 22.04 +
VirtualBox). Nothing needs to be built: the finished system is the disk image
`ft_linux.vdi`, whose SHA-1 is in [`../checksum.txt`](../checksum.txt).
(The [`build/`](../build/) scripts are how that image was made, on another host.)

| File | Runs where | What it does |
|---|---|---|
| [`01_verify.sh`](01_verify.sh) | school PC | `shasum < ft_linux.vdi` compared with `checksum.txt` |
| [`02_create_vm.sh`](02_create_vm.sh) | school PC | creates the VirtualBox VM with the right settings, disk attached **immutable** |
| [`ft_check.sh`](ft_check.sh) | inside ft_linux (`ft_check`) | checks every requirement of the subject, live |

## 1. Get the disk image (before the defense)

```bash
cd ~/goinfre                       # the home quota is too small for a VM
wget https://github.com/emptydeepblue/ft_linux/releases/download/v1.0.0/ft_linux.vdi.xz
                                   # or copy it from a USB drive (exFAT: file > 4 GB)
xz -dk ft_linux.vdi.xz             # -> ft_linux.vdi (keeps the .xz)
git clone https://github.com/emptydeepblue/ft_linux.git ft_linux-repo
```

## 2. Verify it is the submitted image

```bash
bash ft_linux-repo/eval/01_verify.sh ~/goinfre/ft_linux.vdi
```

## 3. Create and start the VM

```bash
bash ft_linux-repo/eval/02_create_vm.sh ~/goinfre/ft_linux.vdi --start
```

The settings it applies (same as creating the VM by hand in VirtualBox):

| Setting | Value | Why |
|---|---|---|
| Type | Linux, Other Linux (64-bit) | x86_64 system |
| Firmware | **BIOS** (EFI off) | GRUB is installed for i386-pc (MBR) |
| Storage | **SATA (AHCI)**, port 0 | AHCI is built into the kernel (IDE and virtio too, as fallbacks); partitions are found by UUID |
| Network | **NAT**, Intel PRO/1000 MT Desktop (82540EM) | e1000 driver built into the kernel |
| Port forwarding | host `127.0.0.1:2222` → guest `22` | ssh from the PC's terminal |
| Disk type | **Immutable** | changes are discarded at each start: the checksum never changes |
| Hardware clock | UTC | ft_linux keeps its clock in UTC (`/etc/sysconfig/clock`) |
| RAM / CPUs | 2 GB / 2 | |

The image's header is already in the form VirtualBox writes, so attaching it
does not change the file either: step 2 gives the same result before and after.

**Immutable** means anything done inside the VM (e.g. an installed package)
lasts until the VM is powered off. That is enough for the defense, and the
image can be re-verified at any moment with step 2.

## 4. Use it

GRUB starts `vmlinuz-6.16.1-everonel`, then the text login appears.
Work from the PC's own terminal (copy-paste, scrollback):

```bash
ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
```

The two `-o` options: the image ships no SSH host key (it is public), so
ft_linux creates new ones at boot, and with an immutable disk that happens at
every start. Without them `ssh` would refuse the "changed" key.

Home test with VirtualBox on Windows (`VBOXMANAGE=…/VBoxManage.exe` from
WSL): the forwarded port is on *Windows'* `127.0.0.1`, which WSL2 cannot
reach ("Connection refused"). Run the same `ssh` from PowerShell.

Root password: *given at the defense*.

## 5. What to show

```bash
ft_check                     # every requirement, one line each
uname -r; hostname           # 6.16.1-everonel, everonel
lsblk; swapon --show         # root, /boot, swap
ls /usr/src/ /boot/

# download source code and install a package
cd /tmp
wget https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz
tar xf hello-2.12.1.tar.gz && cd hello-2.12.1
./configure --prefix=/usr && make && make install
hello
```

## Afterwards

```bash
bash ft_linux-repo/eval/01_verify.sh ~/goinfre/ft_linux.vdi   # same hash as before
bash ft_linux-repo/eval/02_create_vm.sh --remove              # deletes the VM, keeps the .vdi
```
