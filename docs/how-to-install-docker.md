# How to install Docker

Pick a Docker version: `test` or `get` (i.e., stable).

```sh
DOCKER_VERSION="test" # or "get" if you're scared
```

Download and run the Docker installer script.

```sh
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -
```

If you're using a Raspberry Pi or other ARM-based computer, [skip to the RPi section](#rpi). Pick a version of `docker-compose` from the [releases](https://github.com/docker/compose/releases).

```sh
DOCKER_COMPOSE_VERSION="1.27.4"
```

Download `docker-compose`.

```sh
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Make `docker-compose` executable.

```sh
sudo chmod +x /usr/local/bin/docker-compose
```

Add the user to the `docker` group.

```sh
sudo adduser $(whoami) docker
```

Set primary group to `docker`. (Or log out and back in.)

```sh
newgrp docker
```

Test some docker commands.

```sh
docker ps
docker run hello-world
```

## One-liner

The above instructions are summarized in the following script.

```sh
curl -fsSL https://raw.githubusercontent.com/3ch01c/3ch01c.github.io/master/scripts/install_docker.sh | sh -
```

<a name="rpi"></a>
## Install `docker-compose` on Raspberry Pi (or other ARM device)

Instead of installing the pre-built `docker-compose` binary, install it with `pip`.

```sh
sudo apt update
sudo apt install -y python3 python3-pip libffi-dev python-backports.ssl-match-hostname
sudo pip3 install docker-compose
```

## Enable experimental features

Add the `"experimental": true` key to the server configuration in `/etc/docker/daemon.json`. If this file doesn't already exist, you can use the following to create it:

```sh
sudo tee /etc/docker/daemon.json <<EOF
{
  "experimental": true
}
EOF
```

Restart the daemon.

```sh
sudo systemctl restart docker
```

Add the `"experimental": enabled` key to the client configuration in `$HOME/.docker/config.json`. If this file doesn't already exist, you can use the following to create it:

```sh
sudo tee $HOME/.docker/config.json <<EOF
{
  "experimental": enabled
}
EOF
```

Check experimental features are enabled for both the server and client.

```sh
docker version
```

## References

[https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
[https://thenewstack.io/how-to-enable-docker-experimental-features-and-encrypt-your-login-credentials/](https://thenewstack.io/how-to-enable-docker-experimental-features-and-encrypt-your-login-credentials/)

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTQwMjUyNTQ4MCw2ODQxNjE2MzYsLTc4ND
QyMDkwNywtMTI1ODkxMzAyMSwxMDg3NTUwMDMyXX0=
-->
