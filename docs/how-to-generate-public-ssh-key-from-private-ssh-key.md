# How to generate a public SSH key from private SSH key

``` sh
PRIVATE_KEY=~/.ssh/id_rsa
ssh-keygen -y -f $PRIVATE_KEY > $PRIVATE_KEY.pub
```

To do it in batch for a bunch of `.pem` files:

``` sh
find . -name "*.pem" -exec ssh-keygen -y -f {} > {}.pub \;
```
