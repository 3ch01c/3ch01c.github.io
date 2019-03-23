# How to change brightness in XFCE

_From [ubuntuforums.org](https://ubuntuforums.org/showthread.php?t=2198860)_

Edit `/sys/class/backlight/intel_backlight/brightness`:

```
sudo nano /sys/class/backlight/intel_backlight/brightness
```

I think `1` is the lowest visible setting. You could try `0`, but it might turn your screen completely off and then I don't know how you'd get it back.
