# Ansible

## Installation

Install Ansible via Homebrew.

```sh
brew install ansible
```

## Set Up Ubuntu K8s Cluster Node

Set up inventory file.

```sh
[ubuntu]
server1 ansible_host=192.168.100.101
server2 ansible_host=192.168.100.102
server3 ansible_host=192.168.100.103

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```
