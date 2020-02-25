# How to install Archer T2UH drivers on Raspbian

This guide was written using `4.19.105-v7+` kernel. You can check your kernel version with `uname`.

```sh
$ uname -r
4.19.105-v7+
```

Install the kernel headers for your system.

```sh
git clone https://github.com/raspberrypi/firmware --branch $(zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }')
git clone https://github.com/raspberrypi/linux.git --branch $(cat firmware/extra/git_hash)
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
eyJoaXN0b3J5IjpbLTY1MDczMjE2LDY1NDU3MjM2NiwxNDE5Nz
Q4MTgzLDcwNjUwNDkzNiwyMjUyNTQ4NDIsMTYyMzA5NTg2Myw3
MTQ2NDc0NTksLTQzMjMzNjg3Ml19
-->