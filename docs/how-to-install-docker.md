# How to install Docker


Pick a Docker version: `test` or `get` (i.e., stable).
```
DOCKER_VERSION="test" # or "get" if you're scared
```

Download and run the Docker installer script.
```
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -
```

Pick a version of `docker-compose` from the [releases](https://github.com/docker/compose/releases).
```
DOCKER_COMPOSE_VERSION="1.25.0-rc2" # or "1.24.1" if you're scared
```

Download `docker-compose`.
```
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Make `docker-compose` executable.
```
sudo chmod +x /usr/local/bin/docker-compose
```

Add the user to the `docker` group.
```
sudo adduser $(whoami) docker
```

Set primary group to `docker`. (Or log out and back in.)
```
newgrp docker
```

Test some docker commands.
```
docker ps
docker run hello-world
```

Profit.

## If you're using Raspberry Pi...
Instead of installing the pre-built `docker-compose` binary, install it with `pip`.
```
sudo apt update
sudo apt install -y python python-pip libffi-dev python-backports.ssl-match-hostname
sudo pip install docker-compose
```

## References
[https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTQwMjUyNTQ4MCw2ODQxNjE2MzYsLTc4ND
QyMDkwNywtMTI1ODkxMzAyMSwxMDg3NTUwMDMyXX0=
-->