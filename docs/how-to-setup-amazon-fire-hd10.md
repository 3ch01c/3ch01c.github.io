# How to set up Amazon Fire HD10

## CAUTION!
This process could **permanently break** your device. You are solely responsible for your actions if you choose to use these instructions. SHA256 checksums (e.g., `f423cf47f837d74dbb7b9541701dae281ac548b2e8df5f556dfd71708c83d786`) are provided to ensure you download the same files I used to make this tutorial. If your checksums don't match, they may be corrupt, incompatible, or malicious. Or they may be just fine. Use good judgment when deciding to trust the source of the downloads. I put some instruction to [restore the stock ROM](#restore-stock-rom) which will hopefully help if things go really bad.

## Set up your computer

1. Download and install [adb](https://developer.android.com/studio/#command-tools). (SHA256 `7e81d69c303e47a4f0e748a6352d85cd0c8fd90a5a95ae4e076b5e5f960d3c7a`). (Here's a [guide](https://www.xda-developers.com/install-adb-windows-macos-linux/) if you need help.)
2. If you're using Windows, also download and install the [Kindle Fire USB driver](https://s3.amazonaws.com/android-sdk-manager/redist/kindle_fire_usb_driver.zip) (SHA256 `f423cf47f837d74dbb7b9541701dae281ac548b2e8df5f556dfd71708c83d786`).

## Set up the tablet

1. Begin device setup. When you get to the step to connect to WiFi, select an access point, then go back and choose _Not now_ to skip WiFi setup.
2. Go to _Settings_ > _Device Options_ and tap _Serial Number_ 7 times to unlock _Developer Options_.
3. Go to _Developer Options_ then toggle on _Enable ADB_.
4. Go to _Settings_ > _Security & Privacy_ and toggle on _Apps from Unknown Sources_. Tap _OK_ on the _Warning_ dialog.
5. Connect the tablet to your computer and select _OK_ from the _Allow USB debugging_ dialog. (Here's a [guide](https://developer.amazon.com/docs/fire-tablets/connecting-adb-to-device.html) if you need help.)

## Install NoRoot Firewall

System updates could prevent you from rooting or otherwise modifying your device. You can create a firewall to block updates.

1. Download and install [NoRoot Firewall](https://apkpure.com/noroot-firewall/app.greyshirts.firewall). ([alternate link](https://drive.google.com/open?id=1mD0xvDcRSvhi3D6GFkrt4EPjjfyqWC6X) SHA256 `b8c7e4fd106c3be8fa0cf02d4d1ff805b9e858f8328fa0f88ca1b91581323bc5`).

``` sh
adb install "NoRoot Firewall_v3.0.1_apkpure.com.apk"
```

2. Open up _NoRoot Firewall_ app on the tablet, tap _Start_ to start the firewall, check _Auto start on boot_, tap the _Apps_ tab, and X both boxes next to _DeviceSOftwareOTA_ to block it from network access.
3. You can now connect to the internet without getting system updates.

## Root the tablet

_Adapted from [retyre's XDA guide](https://forum.xda-developers.com/hd8-hd10/general/hd-10-2017-offline-rooting-t3734860)_

1. Download the [root exploit code](http://myphone-download.wondershare.cc/mgroot/20165195.zip) ([alternate link](https://drive.google.com/open?id=1Yy9oS0bfy5tNXbEsfOToAr5HR_BBPJwb) SHA256 `8bfc3d5c75964e5fa28c8ffa39a87249ba10ea4180f55f546b2dcc286a585ea8`) and [Super_SU18+](http://myphone-download.wondershare.cc/mgroot/SuperSU_18+.zip) ([alternate link](https://drive.google.com/open?id=1auPqhetUxTB9Kz3_AjfvA65ZaF_Bv6nJ) SHA256 `b572c1a982d1e0baeb571d3bc0df7f6be11b14553c181c9e0bf737cc4a4fbbfd`).

``` sh
wget -c "http://myphone-download.wondershare.cc/mgroot/20165195.zip" "http://myphone-download.wondershare.cc/mgroot/SuperSU_18+.zip"
```

2. Unzip them both to a `20165195` directory.

``` sh
unzip -u 20165195.zip -d 20165195 && unzip -u SuperSU_18+.zip -d 20165195
```

3. Check the `20165195` directory contains all the needed files.

``` sh
$ ls -1 20165195
Matrix
Superuser.apk
ddexe
debuggerd
fileWork
install-recovery.sh
krdem
mount
patch_boot.sh
pidof
push_root.sh
start_wssud.sh
su
su_arm64
supersu.zip
supolicy
toolbox
wsroot.sh
```

4. Push the directory to the tablet.

``` sh
adb push 20165195 /data/local/tmp
```

5. Login to the tablet.

``` sh
adb shell
```

6. Make the files executable.

``` sh
chmod 755 /data/local/tmp/20165195/*
```

<a name="#run-the-exploit"></a>
7. Run the exploit. You should see a lot of output while it runs.

``` sh
/data/local/tmp/20165195/Matrix /data/local/tmp/20165195 2
```

If the script executes successfully, the final lines of output should display the memory location that was exploited (may be different than `0x7fab64c000`) and a value of `0` for `<Exploit>` and `<Done>`. If it fails, check the [Troubleshooting](#root-exploit-failed) section:

```
[*] exploited 0x7fab64c000=f97cff8c
end!!!!!!!
<WSRoot><Exploit>0</Exploit></WSRoot>
<WSRoot><Done>0</Done></WSRoot>
```

8. You can verify root with `su`.

``` sh
shell@suez:/ $ su
su
root@suez:/ #
```

9. Back on your computer, download [SuperSU 2.82 SR5 apk](https://www.apkmirror.com/apk/codingcode/supersu/supersu-2-82-sr5-release/supersu-2-82-sr5-android-apk-download/) ([alternate link](https://drive.google.com/open?id=134SCjUgAk62oKPU-wnHIpX_kTQb6oKYw) SHA256 `2c7be9795a408d6fc74bc7286658dfe12252824867c3a2b726c1f3c78cee918b`) and install it to the tablet with `adb`.

``` sh
adb install "eu.chainfire.supersu_2.82-SR5-282_minAPI9(nodpi)_apkmirror.com.apk"
```

10. Open up the SuperSU app on the tablet, tap _Get Started_, then tap _Continue_ and select _Normal_ to update the app. Select _Reboot_ after it is done installing to reboot the tablet.
11. After the tablet reboots, open SuperSU app again, tap on _Settings_ tab, then tap _Default access_, then choose _Grant_.
12. Log in to your tablet.

``` sh
adb shell
```

13. Switch to superuser and delete directories `/data/data-lib/com.wondershare.DashRoot` and `/data/data-lib/wondershare`.

``` sh
su
rm -r /data/data-lib/com.wondershare.DashRoot /data/data-lib/wondershare
```

14. Thumbs up [retyre's XDA guide](https://forum.xda-developers.com/hd8-hd10/general/hd-10-2017-offline-rooting-t3734860).

**NOTE:** Some apps won't run if your system is rooted. If you need these apps, you can [restore stock ROM](#restore-stock-rom).

## Install Xposed

_Adapted from [tkdfriend's XDA post](https://forum.xda-developers.com/hd8-hd10/general/xposed-framework-fire-hd-8-6th-t3549043)_

1. On your computer, download and install [Xposed Installer](https://forum.xda-developers.com/devdb/project/dl/?id=30660&task=get) ([alternate link](https://drive.google.com/open?id=1NUyq6IhxPzvVpHJ7URXmL_GHImmVky-C) SHA256 `fb72044f0a5ca5c691ea6e6e7c64d081d09c0b4ac6c896f286845ad41a3ae971`).

``` sh
adb install XposedInstaller_by_dvdandroid_19_10_18.apk
```

2. Open _Xposed Installer_ app on the tablet.
3. Switch to _NoRoot Firewall_ app and under _Pending Access_ tab, allow _Xposed Installer_ and _Download Manager_.
4. Switch back to _Xposed Installer_ app. Continue past the warning. Tap on _Official_ tab, then under _Framework_, select `xposed-v89-sdk22-arm64`, then tap _Install/Update_. In the _Are you sure?_ dialog, click _OK_.
5. Once it finishes downloading, click _OK_ in the _Are you sure?_ dialog. It should display an _Install/Update_ window that contains the following error:

```
mv: can't rename '/system/bin/app_process64': No such file or directory
Error 1 occurred
```

6. From your desktop, log in to the tablet.

``` sh
adb shell
```

7. Switch to superuser, remount `/system` with write access, and delete `/system/bin/app_process64_xposed`.

``` sh
su
mount -o remount,rw /system
rm /system/bin/app_process64_xposed
```

8. Reboot your device.

``` sh
adb reboot
```

9. Be patient as it displays the _fire_ logo then eventually _Optimizing system storage and applications_. This takes several minutes.
10. Once the tablet reboots, open _Xposed Installer_ app again. You should see a big green checkmark with _Xposed Framework version 89 is active_.
11. Thumbs up [tkdfriend's XDA guide](https://forum.xda-developers.com/hd8-hd10/general/xposed-framework-fire-hd-8-6th-t3549043) and [coltxL2717's XDA post](https://forum.xda-developers.com/showpost.php?p=70607706&postcount=4) for figuring this out.
12. **Be cautious with Xposed modules!** They can break your device. Make a backup before you add a module and only install one at a time. Some suggested modules:
  * AdBlocker Reborn
  * YouTube AdAway
  * XPrivacy
  * Per App Hacking

## Install FlashFire

This process requires root, Xposed, and Xposed module _Per App Hacking_.

1. Download and install [FlashFire v0.24](https://forum.xda-developers.com/attachment.php?attachmentid=4517344&d=1528041165) ([alternate link]() SHA256 `b8edcfa8a684dbd880780eb5d7dcee9b3f09bf0ecaf8b636df4740a48c5f8644`), but **do not open the app yet.**

``` sh
adb install ff_free_v0.24.apk
```

2. Log in to the tablet.

``` sh
adb shell
```

3. Switch to superuser, remount `/system` as writable, and move FlashFire and SuperSU apps to `/system/app`.

``` sh
su
mount -o remount,rw /system
cp -r /data/app/eu.chainfire.flash-1 /system/app/ && rm -r /data/app/eu.chainfire.flash-1
cp -r /data/app/eu.chainfire.supersu-1 /system/app/ && rm -r /data/app eu.chainfire.supersu-1
```

4. Reboot the tablet.

## Install Google Play Store

1. Download and unzip [Amazon Fire 5th Gen Supertool](http://rootjunkysdl.com/files/?dir=Amazon%20Fire%205th%20gen/SuperTool) ([alternate link](https://drive.google.com/open?id=1xv4HOTvtHJdleEd4JuUQCH20WgZY_Z78) SHA256 `49172c338c501e3455f4b9a9ff40f36493496cd4a92222f77d7fa1901ff47b81`).
2. Run the script `1-Amazon-Fire-5th-gen.bat` on Windows or `3-Amazon-Fire-5th-gen-linux-mac.sh` on Linux/macOS.

``` sh
1-Amazon-Fire-5th-gen.bat
```

3. Choose option 2 `Install Google Play store`.
4. When it finishes, reboot the tablet.
5. Go to NoRoot Firewall and allow _Google Account Manager_ and _Google Play Store_.
6. Open Google Play Store and sign in.

## Remove bloatware

Here's a [spreadsheet](https://docs.google.com/spreadsheets/d/19KAt3uzWB-13F9utW56ITkZaPBNIYF_jYl2tvQV0hrc/edit#gid=1706489423) ([alternate link](https://docs.google.com/spreadsheets/d/1uvY3wJ5cVOGndEKtn96Q51ynIBjLjMHx_NnXWLbxrF0/edit?usp=sharing)) of apps listing which ones are safe to remove or disable.

To get a list of installed packages:

```
adb shell pm list packages
```

To uninstall a package:

```
adb shell pm uninstall PACKAGE_NAME
```

To disable a package:

```
adb shell pm disable PACKAGE_NAME
```

<a name="restore-stock-rom"></a>
## Restore stock ROM

If the tablet won't boot, you can try to recover by reinstalling the stock ROM.

1. Download the [FireOS 5.6.2.0 stock ROM image](wget https://fireos-tablet-src.s3.amazonaws.com/HYVEuFHo7fyolxBkqoyRFW6thr/update-kindle-40.6.1.2_user_612496320.bin
) (SHA256 `2018c579ca34e859644003c1758fd5d72ff6f0ecd47e5453cb82803ddd6b85da`).

``` sh
wget -c https://fireos-tablet-src.s3.amazonaws.com/fqt0doGd1liHKioAFObgRm6oGA/update-kindle-40.6.3.6_user_636558520.bin
```

2. Hold the power and volume decrease buttons simultaneously until the device boots into recovery mode.

``` sh
adb reboot recovery
```

3. Press the volume decrease button to select the option _apply update from adb_ then press the power button.

4. Sideload the stock image with `adb`.

``` sh
adb sideload update-kindle-40.6.1.2_user_612496320.bin
```

5. If the device still won't boot, [contact Amazon customer support](https://www.amazon.com/gp/help/customer/contact-us) to get a replacement.

## Troubleshooting

<a name="root-exploit-failed"></a>
### Root exploit failed
Try rebooting the table then [run the exploit](#run-the-exploit) again if you get an error like this:
```
<WSRoot><Exploit>0x00000332</Exploit></WSRoot>
check done
sched_setaffinity: Function not implemented<WSRoot><Exploit>0x00000382</Exploit></WSRoot>
FAIL : load1 --> /sepolicy
<WSRoot><Exploit>0x00000341</Exploit></WSRoot>
<WSRoot><Exploit>0x00000881</Exploit></WSRoot>
<WSRoot><Done>0x00000172</Done></WSRoot>
```

## Need more help?

Check out the [XDA forums](https://forum.xda-developers.com/hd8-hd10).
