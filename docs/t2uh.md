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
eyJoaXN0b3J5IjpbMjMwNjgyNzYzLDc1MTA0ODk0OCwtMjEwOD
A4NDk5Myw2NTQ1NzIzNjYsMTQxOTc0ODE4Myw3MDY1MDQ5MzYs
MjI1MjU0ODQyLDE2MjMwOTU4NjMsNzE0NjQ3NDU5LC00MzIzMz
Y4NzJdfQ==
-->