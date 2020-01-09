# How to flash stock Nougat on XT1575

_Thanks to [this XDA post](https://forum.xda-developers.com/moto-x-style/general/xt1575-moto-x-pure-edition-factory-t3704142)._

Download and unzip [`CLARK_RETUS_7.0_NPH25.200-22_cid9_subsidy-DEFAULT_CFC.xml.zip`](https://androidfilehost.com/?fid=889964283620765304).

Download and install `fastboot`.

Run the following commands from a command line:
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
