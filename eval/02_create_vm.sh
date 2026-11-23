#!/bin/bash
# 02_create_vm.sh — Create (or remove) the VirtualBox VM that boots ft_linux.
# Who/where: the student, on the evaluation PC, before the defense. No sudo:
# VBoxManage runs as a normal user. Works with VirtualBox 6.1 and 7.x.
#
# Usage:
#   bash eval/02_create_vm.sh /path/to/ft_linux.vdi           create the VM
#   bash eval/02_create_vm.sh /path/to/ft_linux.vdi --start   create and boot it
#   bash eval/02_create_vm.sh --remove                        delete the VM, KEEP the .vdi
#
# The VM files go next to the .vdi (put it in goinfre: the home quota is small).
# Settings, all required by how ft_linux was built:
#   BIOS (no EFI) · SATA/AHCI port 0 = /dev/sda · NAT, Intel PRO/1000 (e1000)
#   · ssh forwarded: host 127.0.0.1:2222 -> VM :22   (ssh -p 2222 root@localhost)
# The disk is attached IMMUTABLE: VirtualBox writes every change to a temporary
# differencing image, reset at each start, so ft_linux.vdi — and its checksum —
# never change, however many times the VM boots.
set -euo pipefail

VM="${FT_VM_NAME:-ft_linux}"
CTL="SATA"
command -v VBoxManage > /dev/null || { echo "ERROR: VBoxManage not found (is VirtualBox installed?)" >&2; exit 1; }

vm_exists() { VBoxManage showvminfo "$VM" > /dev/null 2>&1; }

if [ "${1:-}" = "--remove" ]; then
    vm_exists || { echo "No VM named $VM."; exit 0; }
    VBoxManage controlvm "$VM" poweroff > /dev/null 2>&1 || true
    sleep 2
    # Detach first: 'unregistervm --delete' would also delete attached disks.
    VBoxManage storageattach "$VM" --storagectl "$CTL" --port 0 --device 0 --medium none || true
    VBoxManage unregistervm "$VM" --delete
    echo "VM $VM removed. The .vdi file was not touched."
    exit 0
fi

VDI="${1:?usage: $0 /path/to/ft_linux.vdi [--start]}"
[ -f "$VDI" ] || { echo "ERROR: $VDI not found" >&2; exit 1; }
VDI="$(cd "$(dirname "$VDI")" && pwd)/$(basename "$VDI")"
BASE="$(dirname "$VDI")"

if vm_exists; then
    echo "ERROR: a VM named $VM already exists. Remove it first: bash $0 --remove" >&2
    exit 1
fi

echo "=== Creating VM $VM in $BASE ==="
VBoxManage createvm --name "$VM" --ostype Linux_64 --basefolder "$BASE" --register
VBoxManage modifyvm "$VM" \
    --firmware bios --memory 2048 --cpus 2 --ioapic on --rtcuseutc on \
    --boot1 disk --boot2 none --boot3 none --boot4 none \
    --nic1 nat --nictype1 82540EM \
    --natpf1 "ssh,tcp,127.0.0.1,2222,,22"
VBoxManage storagectl "$VM" --name "$CTL" --add sata --controller IntelAhci \
    --portcount 1 --bootable on
VBoxManage storageattach "$VM" --storagectl "$CTL" --port 0 --device 0 \
    --type hdd --medium "$VDI" --mtype immutable

echo ""
echo "VM ready. Start it from the VirtualBox window, or:  VBoxManage startvm $VM"
echo "Then, from this terminal:"
echo "  ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost"

if [ "${2:-}" = "--start" ]; then
    VBoxManage startvm "$VM"
fi
