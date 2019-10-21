# How to install Moto X Pure factory image

## Introduction
This guide is for the [Moto X Pure/Style (XT1575)](https://www.motorola.com/us/products/moto-x-pure-edition), codenamed [clark](https://wiki.lineageos.org/devices/clark).

A factory Android 6.0 (Marshmallow) image as well as official installation instructions are on [Motorola's website](https://motorola-global-portal.custhelp.com/app/standalone/bootloader/recovery-images). A factory Android 7.0 (Nougat) image is hosted [here](https://androidfilehost.com/?fid=889964283620765304).

## Credits
Thanks to [@acejavelin](https://forum.xda-developers.com/member.php?s=9a3fc97ebc2f1ceaebfce7a6f92c5675&u=2001582) for [posting on XDA](https://forum.xda-developers.com/moto-x-style/general/xt1575-moto-x-pure-edition-factory-t3704142).
Thanks to [@Motorola-Firmware-Team](https://androidfilehost.com/?w=profile&uid=24269982087010314) for acquiring and [hosting an Android 7.0 image](https://androidfilehost.com/?fid=889964283620765304).

## Set up environment
Download platform-tools for your operating system [here](https://developer.android.com/studio/releases/platform-tools). Extract the package somewhere.
```
unzip platform-tools_r29.0.4-linux.zip
cd platform-tools_r29.0.4-linux
```

## Download the image
Download one of the image files and unzip it.
```
unzip CLARK_RETUS_7.0_NPH25.200-22_cid9_subsidy-DEFAULT_CFC.xml.zip
cd CLARK_RETUS_7.0_NPH25.200-22_cid9_subsidy-DEFAULT_CFC.xml
```

## Install the image
Connect the device, reboot it into recovery mode, and use `fastboot` to install the image components:
```
fastboot oem lock begin # or `fastboot oem fb_mode_set` if you don't want to re-lock bootloader
fastboot flash partition gpt.bin
fastboot flash bootloader bootloader.img
fastboot flash logo logo.bin
fastboot flash boot boot.img
fastboot flash recovery recovery.img
fastboot flash system system.img_sparsechunk.0
fastboot flash system system.img_sparsechunk.1
fastboot flash system system.img_sparsechunk.2
fastboot flash system system.img_sparsechunk.3
fastboot flash system system.img_sparsechunk.4
fastboot flash system system.img_sparsechunk.5
fastboot flash system system.img_sparsechunk.6
fastboot flash system system.img_sparsechunk.7
fastboot flash system system.img_sparsechunk.8
fastboot flash system system.img_sparsechunk.9
fastboot flash modem NON-HLOS.bin
fastboot erase modemst1 
fastboot erase modemst2
fastboot flash fsg fsg.mbn
fastboot flash bluetooth BTFM.bin
fastboot erase cache
fastboot erase userdata
fastboot erase customize
fastboot erase clogo
fastboot oem lock # or `fastboot oem fb_mode_clear` if you don't want to re-lock bootloader
fastboot reboot
```
The device should boot up with a fresh factory image.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5ODE5Nzg3NjldfQ==
-->