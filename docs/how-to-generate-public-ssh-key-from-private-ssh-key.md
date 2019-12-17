# How to generate a public SSH key from private SSH key

``` sh
PRIVATE_KEY=~/.ssh/id_rsa
ssh-keygen -y -f $PRIVATE_KEY > $PRIVATE_KEY.pub
```

To do it in batch for a bunch of `.pem` files:

``` sh
sudo apt-get update
sudo apt-get install -y ssh-askpass
find . -name "*.pem" | while read -r key; do ssh-keygen -y -f $key > $key.pub; done
```
