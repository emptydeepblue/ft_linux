
### TODO Cross-Compiled Temporary Tools (steps 6–22, installed to `$LFS`)

These are cross-compiled with `--host=$LFS_TGT` and provide a minimal userspace for chroot:

| # | Package | Notes |
|---|---------|-------|
| 6 | M4 | macro processor |
| 7 | Ncurses | terminal library |
| 8 | Bash | shell for chroot |
| 9 | Coreutils | ls, cp, mv, etc. |
| 10 | Diffutils | diff, cmp |
| 11 | File | file type detection |
| 12 | Findutils | find, xargs |
| 13 | Gawk | AWK |
| 14 | Grep | pattern matching |
| 15 | Gzip | compression |
| 16 | Make | build automation |
| 17 | Patch | apply patches |
| 18 | Sed | stream editor |
| 19 | Tar | archiving |
| 20 | Xz | compression |
| 21 | **Binutils** Pass 2 | rebuilt for target |
| 22 | **GCC** Pass 2 | full cross-compiler, bundles GMP/MPFR/MPC |

### Chroot Temporary Tools (steps 23–28, built natively inside chroot)

| # | Package | Notes |
|---|---------|-------|
| 23 | Gettext | i18n (temporary portion only) |
| 24 | Bison | parser generator |
| 25 | Perl | needed by Autoconf/Automake/Texinfo |
| 26 | Texinfo | info documentation |
| 27 | Util-linux | mount, fdisk, etc. |

### Chapter 8 — Final System (in chroot)

All remaining mandatory packages (~60+) built in dependency order. Follow the LFS book chapter 8 order exactly — do not reorder.
