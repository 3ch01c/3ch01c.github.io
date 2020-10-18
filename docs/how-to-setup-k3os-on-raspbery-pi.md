# How to setup k3OS on Raspberry Pi

Get the MAC address of your Pi.

Install dependencies.

```sh
sudo apt-get install -y p7zip-full jq
```

Download the imaging tool.

```sh
git clone https://github.com/sgielen/picl-k3OS-image-generator.git
```

Create a file in the project directory `config/<YOUR PI MAC ADDRESS>.yaml` with the following contents, replacing the `hostname`, `ssh_authorized_keys`, `IPv4`, `Nameservers`, and `dns_nameservers` values with yours.

```yaml
# the hostname you want to use for the Pi
hostname: k3s-1 

# a public key if you intend to use ssh to connect to the node. This is highly recommended since k3OS has no root user.
ssh_authorized_keys:
  - a-valid-ssh-key-from-your-machine

# Ethernet config
write_files:
  - path: /var/lib/connman/default.config
    content: |-
      [service_eth0]
      Type=ethernet
      IPv4=192.168.1.1/255.255.255.0/192.168.1.1
      IPv6=off
      Nameservers=192.168.1.1

k3OS:
  ntp_servers:
    - 0.us.pool.ntp.org
    - 1.us.pool.ntp.org

  dns_nameservers:
    - 192.168.1.1
    - 8.8.8.8
    - 1.1.1.1

  # We are going to disable servicelb and traefik and use some alternatives
  k3s_args:
    - server
    - "--cluster-init"
    - "--disable=traefik,servicelb"
```

Run the image building script.

```sh
./build-image.sh raspberrypi
```
