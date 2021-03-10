#! /bin/bash
# Author: Jack Miner <3ch01c@gmail.com>
# Description: Create a SSHFS mount on Debian-based systems.
# Usage: ./mount-sshfs.sh user@host:/path/to/dir /mnt/dir

src=$1 # e.g. user@host:/path/to/dir
dst=$2 # e.g. /mnt/dir

sudo apt update && sudo apt install sshfs -y
sudo modprobe fuse
sudo usermod -aG fuse $(whoami)
sudo chown root:fuse /dev/fuse
sudo chmod +x /dev/fusermount

sudo mkdir -p $dst
sudo chown $(whoami) $dst
sshfs $src $dst
ls -l $dst
