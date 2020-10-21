# How to setup headless Ubuntu on Raspberry Pi

1. Download the [Raspberry Pi Generic (64-bit ARM) preinstalled server image](https://cdimage.ubuntu.com/releases/20.10/beta/ubuntu-20.10-beta-preinstalled-server-arm64+raspi.img.xz).
1. If you're using a Chromebook, get the [Chromebook Recovery Tool]() to write the image to the SD card. You'll need to convert the xz archive into a zip first.

   ```sh
   xz -d ubuntu-20.10-beta-preinstalled-server-arm64+raspi.img.xz -c | pv | zip ubuntu-20.10-beta-preinstalled-server-arm64+raspi.zip -
   ```

1. Once the SD card is imaged, uncomment the `wifis` section in the `network-config.txt` file on the `system-boot` partition, and add your WiFi information:

   ```yaml
   wifis:
   wlan0:
   dhcp4: true
   optional: true
   access-points:
     "<wifi network name>":
       password: "<wifi password>"
   ```

1. Insert the card into your Pi and turn it on. Log in with the default credentials `ubuntu:ubuntu` and change the password.
1. If your network connection didn't come up, edit the `/etc/netplan/50-cloud-init.yaml` file, and add you WiFi configuration.

   ```yaml
   network:
    ethernets:
        eth0:
            dhcp4: true
            optional: true
    version: 2
    wifis:
      wlan0:
        optional: true
        access-points:
          "<wifi network name>":
            password: "<wifi password>"
        dhcp4: true
   ```
   
1. Apply the configuration.

   ```sh
   sudo netplan --debug apply
   ```
   
1. You should receive an IP address shortly.

   ```sh
   ip a
   ```
