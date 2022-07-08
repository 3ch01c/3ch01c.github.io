# How to convert PKCS12 to cert and key files

```sh
openssl pkcs12 -in filename.pfx -nocerts -out filename.key
openssl pkcs12 -in filename.pfx -clcerts -nokeys -out filename.crt
```
