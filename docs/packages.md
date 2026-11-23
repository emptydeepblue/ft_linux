# Packages — subject list → build script

Every package required by the subject, and the script of
[`build/5_final_system/`](../build/5_final_system/) that builds its final version
(file name = LFS 12.4 section). The book also builds other packages the
subject does not list (Lz4, Zstd, Libxcrypt, OpenSSL, Libelf, Libffi, Python and
its modules, Ninja, Meson…): they are dependencies of the ones below.
Inside ft_linux, `ft_check` verifies that each one is installed.

| Subject | Script | Book | Note |
|---|---|---|---|
| Acl | [`8.25_acl.sh`](../build/5_final_system/8.25_acl.sh) | §8.25 |  |
| Attr | [`8.24_attr.sh`](../build/5_final_system/8.24_attr.sh) | §8.24 |  |
| Autoconf | [`8.46_autoconf.sh`](../build/5_final_system/8.46_autoconf.sh) | §8.46 |  |
| Automake | [`8.47_automake.sh`](../build/5_final_system/8.47_automake.sh) | §8.47 |  |
| Bash | [`8.36_bash.sh`](../build/5_final_system/8.36_bash.sh) | §8.36 |  |
| Bc | [`8.14_bc.sh`](../build/5_final_system/8.14_bc.sh) | §8.14 |  |
| Binutils | [`8.20_binutils.sh`](../build/5_final_system/8.20_binutils.sh) | §8.20 |  |
| Bison | [`8.34_bison.sh`](../build/5_final_system/8.34_bison.sh) | §8.34 |  |
| Bzip2 | [`8.07_bzip2.sh`](../build/5_final_system/8.07_bzip2.sh) | §8.7 |  |
| Check | [`8.59a_check.sh`](../build/5_final_system/8.59a_check.sh) | — | not in the 12.4 book, kept for the subject |
| Coreutils | [`8.59_coreutils.sh`](../build/5_final_system/8.59_coreutils.sh) | §8.59 |  |
| DejaGNU | [`8.18_dejagnu.sh`](../build/5_final_system/8.18_dejagnu.sh) | §8.18 |  |
| Diffutils | [`8.60_diffutils.sh`](../build/5_final_system/8.60_diffutils.sh) | §8.60 |  |
| Eudev | [`8.76_eudev.sh`](../build/5_final_system/8.76_eudev.sh) | §8.76 | replaces the book's *Udev from Systemd* |
| E2fsprogs | [`8.80_e2fsprogs.sh`](../build/5_final_system/8.80_e2fsprogs.sh) | §8.80 |  |
| Expat | [`8.40_expat.sh`](../build/5_final_system/8.40_expat.sh) | §8.40 |  |
| Expect | [`8.17_expect.sh`](../build/5_final_system/8.17_expect.sh) | §8.17 |  |
| File | [`8.11_file.sh`](../build/5_final_system/8.11_file.sh) | §8.11 |  |
| Findutils | [`8.62_findutils.sh`](../build/5_final_system/8.62_findutils.sh) | §8.62 |  |
| Flex | [`8.15_flex.sh`](../build/5_final_system/8.15_flex.sh) | §8.15 |  |
| Gawk | [`8.61_gawk.sh`](../build/5_final_system/8.61_gawk.sh) | §8.61 |  |
| GCC | [`8.29_gcc.sh`](../build/5_final_system/8.29_gcc.sh) | §8.29 |  |
| GDBM | [`8.38_gdbm.sh`](../build/5_final_system/8.38_gdbm.sh) | §8.38 |  |
| Gettext | [`8.33_gettext.sh`](../build/5_final_system/8.33_gettext.sh) | §8.33 |  |
| Glibc | [`8.05_glibc.sh`](../build/5_final_system/8.05_glibc.sh) | §8.5 |  |
| GMP | [`8.21_gmp.sh`](../build/5_final_system/8.21_gmp.sh) | §8.21 |  |
| Gperf | [`8.39_gperf.sh`](../build/5_final_system/8.39_gperf.sh) | §8.39 |  |
| Grep | [`8.35_grep.sh`](../build/5_final_system/8.35_grep.sh) | §8.35 |  |
| Groff | [`8.63_groff.sh`](../build/5_final_system/8.63_groff.sh) | §8.63 |  |
| GRUB | [`8.64_grub.sh`](../build/5_final_system/8.64_grub.sh) | §8.64 |  |
| Gzip | [`8.65_gzip.sh`](../build/5_final_system/8.65_gzip.sh) | §8.65 |  |
| Iana-Etc | [`8.04_iana_etc.sh`](../build/5_final_system/8.04_iana_etc.sh) | §8.4 |  |
| Inetutils | [`8.41_inetutils.sh`](../build/5_final_system/8.41_inetutils.sh) | §8.41 |  |
| Intltool | [`8.45_intltool.sh`](../build/5_final_system/8.45_intltool.sh) | §8.45 |  |
| IPRoute2 | [`8.66_iproute2.sh`](../build/5_final_system/8.66_iproute2.sh) | §8.66 |  |
| Kbd | [`8.67_kbd.sh`](../build/5_final_system/8.67_kbd.sh) | §8.67 |  |
| Kmod | [`8.58_kmod.sh`](../build/5_final_system/8.58_kmod.sh) | §8.58 |  |
| Less | [`8.42_less.sh`](../build/5_final_system/8.42_less.sh) | §8.42 |  |
| Libcap | [`8.26_libcap.sh`](../build/5_final_system/8.26_libcap.sh) | §8.26 |  |
| Libpipeline | [`8.68_libpipeline.sh`](../build/5_final_system/8.68_libpipeline.sh) | §8.68 |  |
| Libtool | [`8.37_libtool.sh`](../build/5_final_system/8.37_libtool.sh) | §8.37 |  |
| M4 | [`8.13_m4.sh`](../build/5_final_system/8.13_m4.sh) | §8.13 |  |
| Make | [`8.69_make.sh`](../build/5_final_system/8.69_make.sh) | §8.69 |  |
| Man-DB | [`8.77_man_db.sh`](../build/5_final_system/8.77_man_db.sh) | §8.77 |  |
| Man-pages | [`8.03_man_pages.sh`](../build/5_final_system/8.03_man_pages.sh) | §8.3 |  |
| MPC | [`8.23_mpc.sh`](../build/5_final_system/8.23_mpc.sh) | §8.23 |  |
| MPFR | [`8.22_mpfr.sh`](../build/5_final_system/8.22_mpfr.sh) | §8.22 |  |
| Ncurses | [`8.30_ncurses.sh`](../build/5_final_system/8.30_ncurses.sh) | §8.30 |  |
| Patch | [`8.70_patch.sh`](../build/5_final_system/8.70_patch.sh) | §8.70 |  |
| Perl | [`8.43_perl.sh`](../build/5_final_system/8.43_perl.sh) | §8.43 |  |
| Pkg-config | [`8.19_pkgconf.sh`](../build/5_final_system/8.19_pkgconf.sh) | §8.19 | pkgconf, the book's drop-in replacement |
| Procps | [`8.78_procps.sh`](../build/5_final_system/8.78_procps.sh) | §8.78 | procps-ng |
| Psmisc | [`8.32_psmisc.sh`](../build/5_final_system/8.32_psmisc.sh) | §8.32 |  |
| Readline | [`8.12_readline.sh`](../build/5_final_system/8.12_readline.sh) | §8.12 |  |
| Sed | [`8.31_sed.sh`](../build/5_final_system/8.31_sed.sh) | §8.31 |  |
| Shadow | [`8.28_shadow.sh`](../build/5_final_system/8.28_shadow.sh) | §8.28 | root password set in `6_boot/06_root_password.sh` |
| Sysklogd | [`8.81_sysklogd.sh`](../build/5_final_system/8.81_sysklogd.sh) | §8.81 |  |
| Sysvinit | [`8.82_sysvinit.sh`](../build/5_final_system/8.82_sysvinit.sh) | §8.82 |  |
| Tar | [`8.71_tar.sh`](../build/5_final_system/8.71_tar.sh) | §8.71 |  |
| Tcl | [`8.16_tcl.sh`](../build/5_final_system/8.16_tcl.sh) | §8.16 |  |
| Texinfo | [`8.72_texinfo.sh`](../build/5_final_system/8.72_texinfo.sh) | §8.72 |  |
| Time Zone Data | [`8.05_glibc.sh`](../build/5_final_system/8.05_glibc.sh) | §8.5 | tzdata, installed inside the Glibc step |
| Udev-lfs Tarball | [`8.76_eudev.sh`](../build/5_final_system/8.76_eudev.sh) | §8.76 | udev-lfs-20230818 rules, installed inside the Eudev step |
| Util-linux | [`8.79_util_linux.sh`](../build/5_final_system/8.79_util_linux.sh) | §8.79 |  |
| Vim | [`8.73_vim.sh`](../build/5_final_system/8.73_vim.sh) | §8.73 |  |
| XML::Parser | [`8.44_xml_parser.sh`](../build/5_final_system/8.44_xml_parser.sh) | §8.44 |  |
| Xz Utils | [`8.08_xz.sh`](../build/5_final_system/8.08_xz.sh) | §8.8 |  |
| Zlib | [`8.06_zlib.sh`](../build/5_final_system/8.06_zlib.sh) | §8.6 |  |

## Added for the evaluation (BLFS 12.4, [`build/7_network/`](../build/7_network/))

| Package | Why |
|---|---|
| libtasn1, p11-kit, make-ca | CA certificates, so HTTPS downloads are trusted |
| Wget | "you must be able to download source code" |
| dhcpcd | network address from VirtualBox's NAT at boot |
| OpenSSH | work on the VM from the PC's terminal (`ssh -p 2222 root@localhost`) |
