# How to install Archer T2UH drivers on Raspbian

This guide was written using `4.19.105-v7+` kernel.

```sh
$ uname -r
4.19.105-v7+
```

Install the kernel headers.

```sh
git clone https://github.com/raspberrypi/firmware --branch $(zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }')
sudo rpi-update $(cat firmware/extra/git_hash)
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
eyJoaXN0b3J5IjpbMTc1MTUwOTY3MywtMjEwODA4NDk5Myw2NT
Q1NzIzNjYsMTQxOTc0ODE4Myw3MDY1MDQ5MzYsMjI1MjU0ODQy
LDE2MjMwOTU4NjMsNzE0NjQ3NDU5LC00MzIzMzY4NzJdfQ==
-->