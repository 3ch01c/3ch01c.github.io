#! /bin/bash
# Author: Jack Miner <3ch01c@gmail.com>
# Description: Creates a CIFS mount point.
# Usage: ./mount-cifs.sh <src> <dst> <user> <pass>

src = "$1" # e.g., //WINHOST/path/to/dir
dst = "$2" # e.g., /mnt/dir
user = "$3"
pass = "$4"
sudo mkdir -p $dst
sudo mount -t cifs -o username=$user,password=$pass $src $dst
