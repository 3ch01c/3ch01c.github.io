# How to install Archer T2UH drivers on Raspbian

This guide was written using `4.19.105-v7+` kernel.

```sh
$ uname -r
4.19.105-v7+
```

Install the kernel headers for your kernel version.

```sh
FIRMWARE_HASH=$(zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }')
KERNEL_HASH=$(wget https://raw.github.com/raspberrypi/firmware/$FIRMWARE_HASH/extra/git_hash -O -)
sudo rpi-update $KERNEL_HASH
sudo apt install raspberrypi-kernel-headers
```

Download the driver source.

```sh
git clone https://github.com/chenhaiq/mt7610u_wifi_sta_v3002_dpo_20130916
```

Make the drivers.

```sh
cd mt7610u_wifi_sta_v3002_dpo_20130916
make
make install
```


> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbOTA1MzIxNDE4LDIzMDY4Mjc2Myw3NTEwND
g5NDgsLTIxMDgwODQ5OTMsNjU0NTcyMzY2LDE0MTk3NDgxODMs
NzA2NTA0OTM2LDIyNTI1NDg0MiwxNjIzMDk1ODYzLDcxNDY0Nz
Q1OSwtNDMyMzM2ODcyXX0=
-->