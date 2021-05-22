# How to setup headless Raspberry Pi

This guide will get you through installing, configuring, and running Raspberry Pi in headless mode (i.e., without a monitor or 

## Download the Raspberry Pi OS image

You can download the Raspberry Pi OS (Raspbian) image [here](https://www.raspberrypi.org/downloads/raspberry-pi-os/). I recommend the Lite version.

## Copy the image to an SD card

If you're using a Chromebook, I recommend the [Chromebook Recovery Utility](https://chrome.google.com/webstore/detail/chromebook-recovery-utili/jndclpdbaamdhonoechobihbbiimdgai/related?hl=en) with its "Use local image" option.

![](../screenshots/chromebook-recovery-utility.png)

Normally, you'd insert the SD card into your Pi now and continue set up with a keyboard and monitor, but since we're doing headless, we have a few extra steps.

## Configure WiFi

This is only required if you're using WiFi. If you're using a wired Ethernet connection, you can skip this step.

Create a file called `wpa_supplicant.conf` to your `boot` partition with the following contents, replacing the `country`, `ssid` and `psk` values with your own. Two-letter country codes can be found [here](https://www.iban.com/country-codes).

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
  ssid="<YOUR WIFI NAME>"
  psk="<YOUR WIFI PASSWORD>"
}
```

If you don't want to use your plaintext WiFi password, you can use the `wpa_passphrase` to generate a PSK.

```sh
$ wpa_passphrase my_ssid
# reading passphrase from stdin
P@ssw0rd!
network={
        ssid="my_ssid"
        #psk="P@ssw0rd!"
        psk=7bd9400bdeab430431b34fd463df8287ed93875aa56bae7d5e703388f647082f
}
```

## Enable SSH

Create an empty file called `ssh` to the root of the `boot` partition of your newly imaged SD card.

## Boot up your Pi

Eject your SD card from your computer and install it into the Pi and turn it on. Give it a few minutes to boot up and check your router's DHCP table for the Pi's address. You should now be able to SSH in with default credentials `pi:raspberry`.
