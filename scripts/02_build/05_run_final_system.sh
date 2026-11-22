#!/bin/bash
# 05_run_final_system.sh — Build the LFS final system (Chapter 8 packages)
# Run INSIDE the chroot as root.
#
# Usage:
#   bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh        # build all steps
#   bash /sources/ft_linux/scripts/02_build/05_run_final_system.sh 26     # resume from step 26
#
# Build order = LFS 12.4 SysV chapter 8 (script file numbers are historical;
# the order below is what counts). Notes:
#   Glibc needs Python at build time: the temporary Python comes from ch. 7
#   (chroot-tools/26_python.sh), no bootstrap hack here.
#   Step 26 — Shadow: INTERACTIVE — prompts for root password.
#   Step 27 — GCC: longest build, 30–90 min.
#   Kmod 34 is Meson-only, so it comes after Ninja/Meson (book §8.58).
#   Check is not in the 12.4 book: kept because the subject lists it.
#   Eudev replaces the book's "Udev from Systemd" (subject requirement).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FS_DIR="$SCRIPT_DIR/final-system"

START="${1:-1}"

STEPS=(
    "01_man_pages.sh:Man-pages"
    "02_iana_etc.sh:Iana-Etc"
    "03_glibc.sh:Glibc"
    "04_zlib.sh:Zlib"
    "05_bzip2.sh:Bzip2"
    "06_xz.sh:Xz"
    "06a_lz4.sh:Lz4"
    "07_zstd.sh:Zstd"
    "08_file.sh:File"
    "09_readline.sh:Readline"
    "10_m4.sh:M4"
    "11_bc.sh:Bc"
    "12_flex.sh:Flex"
    "13_tcl.sh:Tcl"
    "14_expect.sh:Expect"
    "15_dejagnu.sh:DejaGNU"
    "16_pkgconf.sh:Pkgconf"
    "17_binutils.sh:Binutils"
    "18_gmp.sh:GMP"
    "19_mpfr.sh:MPFR"
    "20_mpc.sh:MPC"
    "21_attr.sh:Attr"
    "22_acl.sh:Acl"
    "23_libcap.sh:Libcap"
    "24_libxcrypt.sh:Libxcrypt"
    "25_shadow.sh:Shadow (INTERACTIVE — root password)"
    "26_gcc.sh:GCC (longest build — 30-90 min)"
    "27_ncurses.sh:Ncurses"
    "28_sed.sh:Sed"
    "29_psmisc.sh:Psmisc"
    "30_gettext.sh:Gettext"
    "31_bison.sh:Bison"
    "32_grep.sh:Grep"
    "33_bash.sh:Bash"
    "34_libtool.sh:Libtool"
    "35_gdbm.sh:GDBM"
    "36_gperf.sh:Gperf"
    "37_expat.sh:Expat"
    "38_inetutils.sh:Inetutils"
    "39_less.sh:Less"
    "40_perl.sh:Perl"
    "41_xml_parser.sh:XML::Parser"
    "42_intltool.sh:Intltool"
    "43_autoconf.sh:Autoconf"
    "44_automake.sh:Automake"
    "45_openssl.sh:OpenSSL"
    "47_libelf.sh:Libelf"
    "48_libffi.sh:Libffi"
    "49_python.sh:Python 3"
    "50_flit_core.sh:Flit-core"
    "52a_packaging.sh:Packaging"
    "51_wheel.sh:Wheel"
    "52_setuptools.sh:Setuptools"
    "53_ninja.sh:Ninja"
    "54_meson.sh:Meson"
    "46_kmod.sh:Kmod"
    "55_coreutils.sh:Coreutils"
    "56_check.sh:Check"
    "57_diffutils.sh:Diffutils"
    "58_gawk.sh:Gawk"
    "59_findutils.sh:Findutils"
    "60_groff.sh:Groff"
    "61_grub.sh:GRUB"
    "62_gzip.sh:Gzip"
    "63_iproute2.sh:IPRoute2"
    "64_kbd.sh:Kbd"
    "65_libpipeline.sh:Libpipeline"
    "66_make.sh:Make"
    "67_patch.sh:Patch"
    "68_tar.sh:Tar"
    "69_texinfo.sh:Texinfo"
    "70_vim.sh:Vim"
    "71_markupsafe.sh:MarkupSafe"
    "72_jinja2.sh:Jinja2"
    "73_eudev.sh:Eudev"
    "74_man_db.sh:Man-DB"
    "75_procps.sh:Procps-ng"
    "76_util_linux.sh:Util-linux"
    "77_e2fsprogs.sh:E2fsprogs"
    "78_sysklogd.sh:Sysklogd"
    "79_sysvinit.sh:Sysvinit"
)

echo "=== ft_linux Final System Builder ==="
echo "  Start step : $START / ${#STEPS[@]}"
echo "  MAKEFLAGS  : ${MAKEFLAGS:--j$(nproc)}"
echo ""

TOTAL_START=$(date +%s)

for i in "${!STEPS[@]}"; do
    step=$((i + 1))
    script="${STEPS[$i]%%:*}"
    name="${STEPS[$i]##*:}"

    if [ "$step" -lt "$START" ]; then
        echo "  [skip] $step/${#STEPS[@]} $name"
        continue
    fi

    echo "========================================"
    echo "  Step $step/${#STEPS[@]}: $name"
    echo "========================================"
    t0=$(date +%s)

    bash "$FS_DIR/$script"

    elapsed=$(( $(date +%s) - t0 ))
    echo "  Completed in ${elapsed}s"
    echo ""
done

TOTAL=$(( $(date +%s) - TOTAL_START ))
echo "=== Final system complete in ${TOTAL}s ==="
echo ""
echo "Next: System configuration, kernel build, and bootloader (Chapters 9–10)"
echo "  See notes/steps/build/10_system_config.md"
echo "  and  notes/steps/build/11_kernel_bootloader.md"
