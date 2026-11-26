#!/bin/bash
# Boot step — root password (LFS 12.4 §8.28 does it right after Shadow; moved
# here so that the long chapter 8 runs unattended). INTERACTIVE.
# Needed to log in on the console and over ssh.
set -euo pipefail
echo ">>> Root password"
# Only a real hash ($id$...) counts: after pwconv the field can be a bare "x",
# which `passwd -S` reports as "P" although no password can ever match it.
if awk -F: '$1 == "root" { exit ($2 ~ /^\$/) ? 0 : 1 }' /etc/shadow; then
    read -r -p "  root already has a password. Change it anyway? (answer y or n, NOT the password) [y/N] " answer
    [ "$answer" = y ] || { echo "<<< Root password unchanged"; exit 0; }
fi
passwd root
echo "<<< Root password done"
