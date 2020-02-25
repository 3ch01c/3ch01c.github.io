# How to install Archer T2UH drivers on Raspbian

This guide was written using Raspbian 9.9.

```sh
$ lsb_release -d
Description:	Raspbian GNU/Linux 9.9 (stretch)
```

Install the latest kernel headers.

```sh
git clone https://github.com/raspberrypi/firmware --branch $(zgrep "* firmware as of" /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1 | awk '{ print $5 }')

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
eyJoaXN0b3J5IjpbNzA2NTA0OTM2LDIyNTI1NDg0MiwxNjIzMD
k1ODYzLDcxNDY0NzQ1OSwtNDMyMzM2ODcyXX0=
-->