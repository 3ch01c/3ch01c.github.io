# How to batch rename files

```sh
find . -name "*.key*" -exec rename 's/.key/.pem/' {} \;
```
