# How to install Archer T2UH drivers on Raspbian

This guide was written using `4.19.105-v7+` kernel.

```sh
$ uname -r
4.19.105-v7+
```

Install the kernel headers for your kernel version.

```sh
FIRMWARE_HASH=$(zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }')
KERNEL_HASH=
sudo rpi-update $(wget https://raw.github.com/raspberrypi/firmware/$FIRMWARE_HASH/extra/git_hash -O -)
```

Clone the [mt7610u_wifi_sta_v3002_dpo_20130916](https://github.com/chenhaiq/mt7610u_wifi_sta_v3002_dpo_20130916) project.

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
eyJoaXN0b3J5IjpbLTE3NTM2Njk0MjksNzUxMDQ4OTQ4LC0yMT
A4MDg0OTkzLDY1NDU3MjM2NiwxNDE5NzQ4MTgzLDcwNjUwNDkz
NiwyMjUyNTQ4NDIsMTYyMzA5NTg2Myw3MTQ2NDc0NTksLTQzMj
MzNjg3Ml19
-->