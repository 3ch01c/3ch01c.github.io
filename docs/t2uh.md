# How to install Archer T2UH drivers on Raspbian

This guide was written using Raspbian 9.9.

```sh
$ lsb_release -d
Description:	Raspbian GNU/Linux 9.9 (stretch)
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
eyJoaXN0b3J5IjpbLTQzMjMzNjg3Ml19
-->