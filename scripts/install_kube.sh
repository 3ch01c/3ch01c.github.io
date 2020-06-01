#!/bin/bash
HOSTNAME=$1 # Ex: kube-manager or kube-worker01
CIDR=$2 # Ex: 10.0.0.0/16

if [ -d /etc/apt ]; then
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt install kubeadm -y
fi

# Turn off swap
sudo swapoff -a

# Set hostname to kube-manager or kube-worker##
sudo hostnamectl set-hostname $HOSTNAME

# Initialize the master with your network configuration
sudo kubeadm init --pod-network-cidr=$CIDR

