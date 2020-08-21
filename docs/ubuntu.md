# Ubuntu

## Quick Start

Set up Homebrew.

```sh
sudo apt update && sudo apt install build-essential -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Add Homebrew to your `PATH`.

```sh
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
```

### Master Nodes

Configure static IP.

```sh

```

Create a `TFTPBOOT` path.

```sh
TFTPBOOT="/tftpboot"
sudo mkdir -p "$TFTPBOOT"
```

Install `dnsmasq`.

```sh
sudo apt install dnsmasq -y
```

Reconfigure dnsmasq port in `/etc/dnsmasq.conf` so it doesn't conflict with `systemd-resolved`.

```sh
sudo tee -a /etc/dnsmasq.conf <<< "port=5300"
```

Add PXE configuration in `/etc/dnsmasq.d/pxe.conf`.

```sh
INTERFACE=enp0s3
TFTPBOOT="/tftpboot"
sudo tee /etc/dnsmasq.d/pxe.conf <<EOF
interface=$INTERFACE,lo
bind-interfaces
dhcp-range=$INTERFACE,192.168.0.100,192.168.0.200
dhcp-boot=pxelinux.0
enable-tftp
tftp-root="$TFTPBOOT"
EOF
```

Start dnsmasq.

```sh
sudo systemctl restart dnsmasq
```

Install Ansible.

```sh
brew install ansible
```

Create an inventory file.

```sh
mkdir .ansible
cat <<EOF > .ansible/ubuntu
[servers]
ubuntu1 ansible_host=192.168.100.101
ubuntu2 ansible_host=192.168.100.102
ubuntu3 ansible_host=192.168.100.103

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
```

Download the Ubuntu netboot installer.

```sh
sudo curl -fsSLC - http://archive.ubuntu.com/ubuntu/dists/eoan/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/pxelinux.0 -o $TFTPBOOT/pxelinux.0
```

Download the Ubuntu ISO and extract the kernel and initrd to `$TFTPBOOT`.

```sh
ISO_NAME="groovy-live-server-amd64"
TFTPBOOT="/tftpboot"
curl -fLC - "http://cdimage.ubuntu.com/ubuntu-server/daily-live/current/$ISO_NAME.iso" -O
sudo mkdir /mnt/"$ISO_NAME"
sudo mount "$ISO_NAME.iso" "/mnt/$ISO_NAME"
sudo cp "/mnt/$ISO_NAME/casper/{vmlinuz,initrd}" "$TFTPBOOT"
sudo apt install syslinux-common -y
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$TFTPBOOT"
```

Create default PXE configuration in `$TFTPBOOT/pxelinux.cfg/default`.

```sh
TFTPBOOT="/tftpboot"
ISO_NAME="groovy-live-server-amd64"
sudo mkdir -p "$TFTPBOOT/pxelinux.cfg"
sudo tee "$TFTPBOOT/pxelinux.cfg/default" <<EOF
DEFAULT install
LABEL install
  KERNEL vmlinuz
  INITRD initrd
  APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url="http://$SERVER_IP/$ISO_NAME.iso"
EOF
```
