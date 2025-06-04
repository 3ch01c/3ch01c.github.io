# WSL

## Troubleshooting

### Unable to resolve names

Check `/etc/resolv.conf` to see if there's a name server configuration.

```sh
cat /etc/resolv.conf
```

This should match your host network configuration.

```
nameserver 192.168.1.1
```

### `Logon failure: the user has not been granted the requested logon type at this computer.`

Restart the WSL service.

```powershell
Get-Service vmcompute | Restart-Service
```
