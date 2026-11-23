#!/bin/bash
# Boot step — root password (LFS 12.4 §8.28 does it right after Shadow; moved
# here so that the long chapter 8 runs unattended). INTERACTIVE.
# Needed to log in on the console and over ssh.
set -euo pipefail
echo ">>> Root password"
if passwd -S root | awk '{exit ($2 == "P") ? 0 : 1}'; then
    echo "  root already has a password. Change it anyway? [y/N]"
    read -r answer
    [ "$answer" = y ] || { echo "<<< Root password unchanged"; exit 0; }
fi
passwd root
echo "<<< Root password done"
