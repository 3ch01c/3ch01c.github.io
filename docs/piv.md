# PIV

## Troubleshooting

### Disable PIN pad prompt

If you use OpenSC, the PIN pad prompt can interfere with authentication. TO disable it, add `enable_pinpad = false;` and `md_pinpad_dlg_enable_cancel = true;` to your `opensc.conf`

```
# /Library/OpenSC/etc/opensc.conf

app default {
    # debug = 3;
    # debug_file = opensc-debug.txt;
    framework pkcs15 {
        # use_file_caching = public;
    }
    enable_pinpad = false;
    md_pinpad_dlg_enable_cancel = true;
}
```
```
