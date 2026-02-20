# Package Installation Guide

## Overview

This document lists all mandatory packages required for ft_linux and provides installation guidelines.

## Installation Method

Most packages are compiled from source following the Linux From Scratch (LFS) methodology.

## Build Order

Packages must be installed in a specific order due to dependencies. Follow the LFS book for exact build order.

## Mandatory Packages List

### Core System Libraries

1. **Glibc** - GNU C Library
   - Essential C library
   - Must be installed early

2. **Zlib** - Compression library
   - Required by many packages

3. **GMP** - GNU Multiple Precision Arithmetic Library
   - Required for GCC

4. **MPFR** - Multiple Precision Floating-Point Library
   - Required for GCC

5. **MPC** - Multiple Precision Complex Library
   - Required for GCC

6. **Ncurses** - Terminal handling library
   - Required for interactive programs

7. **Readline** - Line editing library
   - Used by bash and other programs

### Build Tools

8. **Binutils** - Binary utilities
   - Linker, assembler, and other tools

9. **GCC** - GNU Compiler Collection
   - C/C++ compiler

10. **M4** - Macro processor
    - Required for autoconf

11. **Autoconf** - Configure script generator
    - Build tool

12. **Automake** - Makefile generator
    - Build tool

13. **Libtool** - Library creation support
    - Build tool

14. **Make** - Build automation tool

15. **Patch** - File patching utility

16. **Bison** - Parser generator
    - Required for building many packages

17. **Flex** - Lexical analyzer generator

18. **Gperf** - Perfect hash function generator

19. **Perl** - Scripting language
    - Required for many build processes

20. **XML::Parser** - Perl XML parser module

21. **Pkg-config** - Library compilation helper

### Core Utilities

22. **Bash** - Bourne Again SHell
    - Primary shell

23. **Coreutils** - Core GNU utilities
    - ls, cp, mv, rm, etc.

24. **Diffutils** - File comparison utilities

25. **Findutils** - File finding utilities
    - find, xargs

26. **Gawk** - GNU awk
    - Text processing

27. **Grep** - Pattern matching utility

28. **Sed** - Stream editor

29. **Tar** - Archiving utility

30. **Gzip** - Compression utility

31. **Bzip2** - Alternative compression

32. **Xz Utils** - LZMA compression

33. **File** - File type identification

34. **Bc** - Basic calculator

### System Administration

35. **Shadow** - Password management
    - passwd, su, etc.

36. **Util-linux** - Miscellaneous utilities
    - mount, umount, fdisk, etc.

37. **E2fsprogs** - EXT filesystem utilities
    - mkfs.ext4, fsck, etc.

38. **Procps** - Process monitoring
    - ps, top, etc.

39. **Psmisc** - Process utilities
    - killall, pstree, etc.

40. **Sysvinit** - System initialization
    - init, shutdown, etc.

41. **Sysklogd** - System logging daemon

42. **Eudev** (or Udev-lfs) - Device manager
    - Dynamic device management

### Networking

43. **Inetutils** - Network utilities
    - ping, ftp, telnet, etc.

44. **IPRoute2** - Network configuration
    - ip, ss, etc.

### Text Processing & Documentation

45. **Groff** - Text formatting

46. **Texinfo** - Documentation format

47. **Man-DB** - Manual page system

48. **Man-pages** - Manual pages content

49. **Less** - Text pager

50. **Vim** - Text editor
    - Or alternative like nano

### Localization & Time

51. **Gettext** - Internationalization

52. **Intltool** - Internationalization tool

53. **Iana-Etc** - Network protocol data
    - /etc/protocols, /etc/services

54. **Time Zone Data** - Timezone information

### Testing & Verification

55. **Check** - Unit testing framework

56. **DejaGNU** - Testing framework

57. **Expect** - Automated interaction
    - Required for testing

58. **Tcl** - Tool Command Language
    - Required for expect

### Bootloader

59. **GRUB** - GRand Unified Bootloader
    - Or alternative like LILO

### Additional Libraries

60. **Acl** - Access Control Lists

61. **Attr** - Extended attributes

62. **Libcap** - POSIX capabilities

63. **Libpipeline** - Pipeline manipulation

64. **Expat** - XML parser library

65. **GDBM** - GNU database library

### Input/Output

66. **Kbd** - Keyboard utilities
    - loadkeys, setfont

### Module Management

67. **Kmod** - Kernel module tools
    - modprobe, lsmod, etc.

## Installation Example

Generic compilation steps for most packages:

```bash
# Extract
tar -xf package-version.tar.xz
cd package-version

# Configure
./configure --prefix=/usr

# Compile
make

# Test (optional but recommended)
make check

# Install
make install
```

## Package Versions

You are free to choose package versions. Recommendations:
- Follow LFS stable book versions for compatibility
- Or use latest stable releases

## Download Sources

For evaluation, ensure you can download sources:

```bash
# Install wget or curl first
# Example: wget
tar -xf wget-*.tar.gz
cd wget-*
./configure --prefix=/usr --sysconfdir=/etc
make
make install
```

## Verification

After installation, verify packages:

```bash
# Check binaries
which bash gcc make

# Check libraries
ldconfig -p | grep libc

# Test basic commands
bash --version
gcc --version
```

## Installation Tips

1. **Follow dependency order** - Use LFS book chapter order
2. **Test after each package** - Run test suites
3. **Keep build logs** - Useful for troubleshooting
4. **Use separate build directories** - Keep sources clean
5. **Verify installation** - Check files were installed correctly

## Additional Packages (Recommended)

For full functionality:

- **wget** or **curl** - Required for evaluation
- **SSH** - Remote access
- **Git** - Version control (for bonus)

## Resources

- [Linux From Scratch Book](http://www.linuxfromscratch.org/lfs/view/stable/)
- [BLFS (Beyond LFS)](http://www.linuxfromscratch.org/blfs/)
- Package documentation and READMEs