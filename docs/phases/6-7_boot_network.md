# Phases 6–7 — Making it bootable, connecting it

**Book:** LFS 12.4 ch. 9–10, BLFS 12.4 · **Folders:** [`build/6_boot/`](../../build/6_boot/),
[`build/7_network/`](../../build/7_network/) · **Who/where:** root inside the chroot ·
**Status:** reviewed against the books, built (2026-11-25)

```bash
bash $FT_DIR/build/6_boot/run.sh       # bootscripts, /etc, kernel, GRUB, ft_check, root password
bash $FT_DIR/build/7_network/run.sh    # CA certificates, wget, dhcpcd, ssh (needs network)
```

After phase 5 the system has all its programs but cannot start by itself:
nothing tells the kernel where `/` is, nobody starts the services, there is no
kernel yet. Phase 6 adds that. Phase 7 adds what the subject asks for the
evaluation: *download source code and install packages*, plus ssh for comfort.

## 6_boot

| Step | Book | What and why |
|---|---|---|
| 01 Bootscripts | §9.2 | The SysV scripts in `/etc/rc.d/init.d/` that `init` runs at each runlevel: mount file systems, start udev, set the clock, bring up the network, start the logger… |
| 02 System config | §9.5–9.9, §10.2, §11.1 | Everything in `/etc` (values from [`config/ft_linux.conf`](../../config/ft_linux.conf)): `hostname` = **everonel** (subject), `hosts`, DHCP on `eth0`, `inittab` (runlevel 3, six text consoles), clock in UTC, keymap `us`, `profile` (`LANG=C.UTF-8`), `inputrc`, `shells`, **`fstab`**, USB module order, `os-release`. |
| 03 Kernel | §10.3 | Sources unpacked in **`/usr/src/kernel-6.16.1`** (subject), `make defconfig` + [`config/kernel.config`](../../config/kernel.config), then a check that every option of the fragment survived and that the release is **`6.16.1-everonel`**; installed as **`/boot/vmlinuz-6.16.1-everonel`** (subject). |
| 04 GRUB | §10.4 | `grub-install` in the MBR (BIOS, `i386-pc`) and a generated `grub.cfg`. |
| 05 ft_check | — | Installs [`eval/ft_check.sh`](../../eval/ft_check.sh) as `/usr/local/bin/ft_check`: the requirements, checked live during the defense. |
| 06 Root password | §8.28 | The only interactive step, moved here from Shadow so phase 5 runs unattended. |

### The kernel configuration

`defconfig` is a generic x86-64 configuration: no tuning for the build
machine's CPU, so the kernel runs on any PC. The fragment adds the subject's
identity (`LOCALVERSION`, hostname), the options the book requires (devtmpfs,
cgroups, PSI…) and, **built in (`=y`)**, everything needed to reach `/`
without an initramfs: AHCI (SATA), PIIX (IDE), virtio-blk; ext4; e1000/e1000e,
PCnet and virtio-net for the network. Modules (`=m`) would only be loadable
*after* `/` is mounted. Verified on the real 6.16.1 sources: no option lost.

### No device names: UUID and PARTUUID

The disk is built as a loop device (`/dev/loopN`, the number varies) and boots as `/dev/sda` — or something else
if the VM is set up differently. So nothing refers to device names:

- `fstab` mounts `/`, `/boot` and swap by **file-system UUID**;
- GRUB finds `/boot` by its UUID (`search --fs-uuid`);
- the kernel gets **`root=PARTUUID=…`** (MBR disk signature + partition number),
  which it understands on its own, unlike `root=UUID=` (needs an initramfs);
  `rootwait` makes it wait for the disk to be detected.

`net.ifnames=0` keeps the classic `eth0` name, used by `ifconfig.eth0`.

## 7_network (BLFS 12.4)

| Step | What and why |
|---|---|
| 01 libtasn1, 02 p11-kit | Libraries for the certificate store; `update-ca-certificates` goes through make-ca. |
| 03 make-ca | Downloads Mozilla's CA list and builds `/etc/ssl/certs`, `/etc/pki/tls/certs/ca-bundle.crt`: without it, every HTTPS download fails. **Needs network inside the chroot** (WSL's works). |
| 04 Wget | HTTPS downloads through OpenSSL; a non-fatal test at the end. Built without libpsl (an optional cookie-security library). |
| 05 dhcpcd | Gets an address from VirtualBox's NAT at boot (`SERVICE=dhcpcd` in `ifconfig.eth0`), as unprivileged user `dhcpcd`; plus its boot service from blfs-bootscripts. |
| 06 OpenSSH | `sshd` at boot, so the VM can be used from the PC's terminal (`ssh -p 2222 root@localhost`, see [eval/](../../eval/README.md)). |

### SSH choices

- **Root may log in with a password** (`PermitRootLogin yes`; BLFS suggests `no`
  for a real server): the VM is reachable only from the PC running it.
- **No host key in the image:** the image is public, so the keys `make install`
  creates are deleted, and the boot script runs `ssh-keygen -A` before `sshd`.
  With an immutable disk they change at every start: hence the `-o` options in
  the ssh command of `eval/README.md`.

## What the review changed (2026-11-23)

- `fstab` and `grub.cfg` used `/dev/sda2` / `(hd0,msdos1)` → UUID, PARTUUID, `rootwait`.
- Kernel: PCnet and virtio drivers added as fallbacks (fragment re-verified on the 6.16.1 sources).
- Added: OpenSSH (06), the `ft_check` install (05), root password (06 of 6_boot);
  `build/sync_to_lfs.sh` now copies `eval/` into the chroot too.
- dhcpcd sends the host name (`-h $HOSTNAME`, as in BLFS); the VM's clock is set to UTC.
- `inittab` compared with the book: identical.

Next: [Phase 8 — the evaluation disk](8_release.md).
