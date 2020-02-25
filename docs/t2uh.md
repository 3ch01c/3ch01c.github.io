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
```

Clone the drivers.

```sh
git clone https://github.com/chenhaiq/mt7610u_wifi_sta_v3002_dpo_20130916
```

Move into the project directory.

```sh
cd mt7610u_wifi_sta_v3002_dpo_20130916
```

Build the driver.

```sh
make
make install
```


> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTg2MDgwNTIxMCw3NTEwNDg5NDgsLTIxMD
gwODQ5OTMsNjU0NTcyMzY2LDE0MTk3NDgxODMsNzA2NTA0OTM2
LDIyNTI1NDg0MiwxNjIzMDk1ODYzLDcxNDY0NzQ1OSwtNDMyMz
M2ODcyXX0=
-->