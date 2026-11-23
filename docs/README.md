# Documentation

| Read this | For |
|---|---|
| [concepts.md](concepts.md) | the *why*: bootstrapping, toolchain, boot chain, FHS, init, udev, GRUB |
| [phases/](phases/) | one page per folder of `build/`: what each step does, why, deviations from the book |
| [packages.md](packages.md) | every package of the subject → the script that builds it |
| [cheatsheet.md](cheatsheet.md) | questions and answers for the defense |
| [issues.md](issues.md) | problems met during the build and their fixes |
| [../eval/README.md](../eval/README.md) | running ft_linux on a school PC |

The commands are in the scripts, not here: each page says what a script does
and why, and links to it. How to run everything, in order: [README](../README.md).

## Phases

| Page | build/ | Book |
|---|---|---|
| [1_host](phases/1_host.md) | `1_host/` | ch. 2–4 |
| [2_toolchain](phases/2_toolchain.md) | `2_toolchain/` | ch. 5–6 |
| [3-4_chroot](phases/3-4_chroot.md) | `3_chroot/`, `4_chroot_tools/` | ch. 7 |
| [5_final_system](phases/5_final_system.md) | `5_final_system/` | ch. 8 |
| [6-7_boot_network](phases/6-7_boot_network.md) | `6_boot/`, `7_network/` | ch. 9–10, BLFS |
