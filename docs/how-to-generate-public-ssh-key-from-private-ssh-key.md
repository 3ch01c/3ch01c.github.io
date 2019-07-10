# How to generate a public SSH key from private SSH key
```
PRIVATE_KEY=~/.ssh/id_rsa
ssh-keygen -y -f $PRIVATE_KEY > $PRIVATE_KEY.pub
```
