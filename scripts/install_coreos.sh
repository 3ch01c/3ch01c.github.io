#!/bin/bash
# [Fedora CoreOS working on Virtualbox](https://jjasghar.github.io/blog/2020/05/26/fedora-coreos-working-on-virtualbox/)
# [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads).
# [Download CoreOS ISO](https://getfedora.org/en/coreos/download?tab=metal_virtualized&stream=stable)

# Create a new VM
VM_NAME="CoreOS"
VM_BASEFOLDER="${HOME}/Virtualbox VMs"
# * Select Fedora 64-bit
VM_OSTYPE="Fedora_64"
# * Give the VM at least 4 Gigs, I gave mine 8 Gigs
VM_MEMORY=8192
VM_CPUS=8
# * 16 Gigs for the hard drive to test
VDI_FILENAME="${VM_BASEFOLDER}/${VM_NAME}/CoreOS.vdi"
VDI_SIZE=32768
# * Set the network to “NAT” and add the following to the port forwarding:
# * Host IP: 127.0.0.1
# * Host Port: 2222
# * Guest IP: 10.0.2.15
# * Guest Port: 22
VM_NATPF1="guestssh,tcp,,2222,,22"
# * Mount the LiveCD as an Optical Device
# * Confirm that you’ll boot off it as your first device
COREOS_ISO="${HOME}/computing/iso/linux/fcos/fedora-coreos-32.20200629.3.0-live.x86_64.iso"

VBoxManage unregistervm "$VM_NAME" --delete
VBoxManage createvm --name="$VM_NAME" --basefolder="$VM_BASEFOLDER" --ostype="$VM_OSTYPE" --default --register
VBoxManage modifyvm "$VM_NAME" --memory=$VM_MEMORY --cpus=$VM_CPUS --natpf1="$VM_NATPF1"
# Create new VDI
VBoxManage closemedium disk "$VDI_FILENAME" --delete
VBoxManage createmedium disk --filename="$VDI_FILENAME" --size=$VDI_SIZE
#VBoxManage modifymedium disk "$VDI_FILENAME" --compact
VBoxManage storageattach "$VM_NAME" --storagectl="IDE" --port=0 --device=0 --type=hdd --medium="$VDI_FILENAME"
# Mount ISO
# VBoxManage createmedium dvd --filename="$COREOS_ISO" --size=
# VBoxManage storageattach "$VM_NAME" --storagectl="SATA" --port=0 --device=0 --type dvddrive --medium="$COREOS_ISO"
VBoxManage unattended install "$VM_NAME" --iso="$COREOS_ISO"
# Start VM
VBoxManage startvm "$VM_NAME"
# Set up ignition
#cat <<EOF >
#variant: fcos
#version: 1.0.0
#passwd:
#  users:
#    - name: core
#      ssh_authorized_keys:
#        - ssh-rsa AAAA...
#EOF