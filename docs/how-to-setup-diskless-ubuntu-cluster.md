# How to setup diskless Ubuntu cluster

## Set up the image server

This assumes a machine with a clean installation of Ubuntu 20.04 Server and two network interfaces: `enp0s3` connected to the WAN 10.0.0.0/8, and `enp0s8` connected to the cluster LAN (192.168.2.0/24).

1. Install dependencies.

   ```sh
   sudo apt-get update -y
   sudo apt-get install -y isc-dhcp-server iptables-persistent tftpd-hpa syslinux pxelinux nfs-kernel-server initramfs-tools
   ```

2. Configure the cluster network interface `enp0s8` to use static IP address `192.168.2.1`. Make sure to set the gateway as the IP address of the WAN interface.

   ```sh
   sudo tee /etc/netplan/01-netcfg.yaml <<EOF
   network:
    version: 2
    ethernets:
      enp0s8:
        dhcp4: no
        addresses:
          - 192.168.2.1/24
        gateway4: 10.0.2.15
        nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
   EOF
   ```

3. Apply the new IP configuration.

   ```sh
   sudo netplan apply
   ```

4. Configure the DHCP service for the cluster network `192.168.2.0/24`.

   ```sh
   sudo tee /etc/dhcp/dhcpd.conf <<EOF
   allow booting;
   allow bootp;

   # Don't serve DHCP on the WAN
   subnet 10.0.0.0 netmask 255.0.0.0 {
   }

   subnet 192.168.2.0 netmask 255.255.255.0 {
     range 192.168.2.2 192.168.2.254;
     option broadcast-address 192.168.2.255;
     option routers 192.168.2.1;
     option domain-name-servers 8.8.8.8, 1.1.1.1;

     filename "/tftpboot/pxelinux.0";
   }

   # Optional: Add custom configuration for specific MAC addresses. Replace x's accordingly.
   #host pxe_client {
   #  hardware ethernet xx:xx:xx:xx:xx:xx;
   #  fixed-address 192.168.2.2;

   #  filename "/tftpboot/pxelinux.1";
   #}
   EOF
   ```

5. Restart the DHCP service to apply new configuration.

   ```sh
   sudo service isc-dhcp-server restart
   ```

6. Configure iptables to forward NAT traffic on the WAN interface `enp0s3`.

   ```sh
   sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
   sudo iptables --table nat -A POSTROUTING -o enp0s3 -j MASQUERADE
   sudo iptables-save | sudo tee /etc/iptables/rules.v4
   ```

7. Create a TFTP directory and add PXE resources to it.

   ```sh
   sudo mkdir -p /tftpboot/{pxelinux.cfg,boot}
   sudo cp /usr/lib/PXELINUX/pxelinux.0 /tftpboot
   sudo cp -r /usr/lib/syslinux/modules/bios /tftpboot/boot/isolinux
   ```

   <a name="pxe-config"></a>
8. Create a default PXE configuration.

   ```sh
   sudo tee /tftpboot/pxelinux.cfg/default <<EOF
   DEFAULT linux
   LABEL linux
   KERNEL vmlinuz-$(uname -r)
   APPEND root=/dev/nfs netboot=nfs initrd=initrd.img-$(uname -r) nfsroot=192.168.2.1:/nfsroot ip=dhcp rw debug
   EOF
   ```

9. Configure permissions of TFTP resources.

   ```sh
   sudo chmod -R 777 /tftpboot
   ```

10. Configure TFTP service.

    ```sh
    sudo tee /etc/default/tftpd-hpa <<EOF
    TFTP_USERNAME="tftp"
    TFTP_DIRECTORY="/tftpboot"
    TFTP_ADDRESS=":69"
    RUN_DAEMON="yes"
    OPTIONS="-l -s /tftpboot"
    EOF
    ```

11. Start the TFTP service.

    ```sh
    sudo /etc/init.d/tftpd-hpa start
    ```

12. Create directories to share OS files and NFS configurations.

    ```sh
    sudo mkdir -p /nfsroot
    sudo mkdir -p /etc/exports.d
    ```

13. Create NFS configuration to export OS resources to the cluster network `192.168.2.0/24`.

    ```sh
    sudo tee /etc/exports.d/nfsroot.exports <<EOF
    /nfsroot 192.168.2.0/24(rw,no_root_squash,async,insecure)
    EOF
    ```

14. Apply NFS configuration.

    ```sh
    sudo exportfs -rv
    ```

## Generate the worker image

This assumes another machine running Ubuntu 20.04 Server configured as a worker and connected to the cluster network `192.168.2.0/24` via DHCP.

1. Install dependencies.

   ```sh
   sudo apt-get update
   sudo apt-get install -y nfs-common
   ```

2. Mount the image server's NFS share for OS resources `192.168.2.1:/nfsroot`.

   ```sh
   sudo mkdir /nfsroot
   sudo mount -t nfs 192.168.2.1:/nfsroot /nfsroot
   ```

3. Configure initramfs to netboot using NFS.

   ```sh
   sudo tee -a /etc/initramfs-tools/initramfs.conf <<< BOOT=nfs
   sudo sed -iE 's/^MODULES=.*$/MODULES=netboot/' /etc/initramfs-tools/initramfs.conf
   ```

4. Add required modules to `/etc/initramfs-tools/modules`.

   ```sh
   sudo tee -a /etc/modules-load.d/modules.conf <<EOF
   i2c_piix4
   EOF
   ```

5. Generate `initrd` image and copy the image and the active kernel to the NFS share.

   ```sh
   sudo mkinitramfs -o ~/initrd.img-`uname -r`
   sudo cp -ax initrd.img-`uname -r` /boot/vmlinuz-`uname -r` /nfsroot/
   ```

6. Copy the root filesystem to the NFS share.

   ```sh
   sudo cp -ax /. /nfsroot/.
   sudo cp -ax /dev/. /nfsroot/dev/.
   ```

7. Modify `/nfsroot/etc/fstab` to mount use the NFS share defined in the [PXE config](#pxe-config) as the root filesystem and `/tmp`, `/var/run`, `/var/lock`, and `/var/tmp` as `tmpfs`.

   ```sh
   sudo tee /nfsroot/etc/fstab <<EOF
   # /etc/fstab: static file system information.
   #
   # <file system> <mount point>   <type>  <options>       <dump>  <pass>
   proc            /proc           proc    defaults        0       0
   /dev/nfs        /               nfs4    defaults        0       0
   none            /tmp            tmpfs   defaults        0       0
   none            /var/run        tmpfs   defaults        0       0
   none            /var/lock       tmpfs   defaults        0       0
   none            /var/tmp        tmpfs   defaults        0       0
   /dev/hdc        /media/cdrom0   udf,iso9660 user,noauto 0       0
   EOF
   ```

8. Disable Grub updates.

    ```sh
    sudo sed -i 's/exec update-grub/#exec update-grub/' /nfsroot/etc/kernel/postinst.d/zz-update-grub
    ```

9. Optional: Restore the local initramfs configuration to allow booting from local disk.

   ```sh
   sudo sed -iE 's/^MODULES=netboot/MODULES=most/' /etc/initramfs-tools/initramfs.conf
   sudo sed -iE 's/^BOOT=nfs/BOOT=local/' /etc/initramfs-tools/initramfs.conf
   ```

10. Back on the image server, move the boot packages from the NFS share to the TFTP share.

   ```sh
   sudo mv /nfsroot/initrd.img-* /nfsroot/vmlinuz-* /tftpboot/
   ```

<!--
9.  Edit network settings in `/nfsroot/etc/netplan/00-installer-config.yaml` so we're not making unnecessary DHCP requests.

   ```sh
   network:
     ethernets:
       enp0s3:
         dhcp4: false
     version: 2
   ```
-->

11. Configure the worker to boot from network in the BIOS and reboot it. It should pull the PXE images then boot up using the OS exported at `192.168.2.1:/nfsroot`.

## Troubleshooting

You can monitor network traffic on the image server to make sure the hosts are connecting and getting images.

```sh
sudo tcpdump -i enp0s8 -v
```

If you're behind a proxy, you'll need to configure APT and add proxy environment variables.

```sh
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
export no_proxy=127.0.0.1,localhost,.example.com
sudo tee /etc/apt/apt.conf <<EOF
Acquire::http::Proxy "http://proxy.example.com:8080";
Acquire::https::Proxy "http://proxy.example.com:8080";
EOF
```

## Reference

- [DisklessUbuntuHowto](https://help.ubuntu.com/community/DisklessUbuntuHowto)
- [NAT Gateway, Iptables, Port Forwarding, DNS And DHCP Setup - Ubuntu 8.10 Server](https://www.howtoforge.com/nat-gateway-iptables-port-forwarding-dns-and-dhcp-setup-ubuntu-8.10-server)
- [Installing, Configuring And Debugging The ISC DHCP Server](https://prefetch.net/articles/iscdhcpd.html)
