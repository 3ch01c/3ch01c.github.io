# How to install Docker

## Install Docker

Pick a Docker version: `test` or `get` (i.e., stable).

```sh
DOCKER_VERSION="test" # or "get" if you're scared
```

Download and run the Docker installer script. If you're using RHEL, you may need to use [this guide](https://docs.docker.com/engine/install/centos/) instead.

```sh
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -
```

Add the user to the `docker` group. Want to [install rootless Docker](https://docs.docker.com/engine/security/rootless) instead?

```sh
sudo usermod -aG docker $USER
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

## Install `docker-compose`

If you're using a Raspberry Pi or other ARM-based computer, [skip to the RPi section](#rpi). Pick a version of `docker-compose` from the [releases](https://github.com/docker/compose/releases).

```sh
DOCKER_COMPOSE_VERSION="v2.6.0"
```

Download `docker-compose`.

```sh
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Make `docker-compose` executable.

```sh
sudo chmod +x /usr/local/bin/docker-compose
```

## One-liner

The above instructions are summarized in the following script.

```sh
curl -fsSL https://raw.githubusercontent.com/3ch01c/3ch01c.github.io/master/sh/install_docker.sh | sh -
```

<a name="rpi"></a>

## Install `docker-compose` on Raspberry Pi (or other ARM device)

Instead of installing the pre-built `docker-compose` binary, install it with `pip`.

```sh
sudo apt update
sudo apt install -y python3 python3-pip libffi-dev python-backports.ssl-match-hostname
sudo pip3 install docker-compose
```

## Install Docker on RHEL

_From [this guide](https://docs.docker.com/engine/install/centos/)_

Add Docker repository for CentOS.

```sh
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

Install packages.

```sh
sudo yum install docker-ce docker-ce-cli containerd.io
```

Start Docker.

```sh
sudo systemctl start docker
```

Test it works.

```sh
sudo docker ps
sudo docker run hello-world
```

If it doesn't work, do you need to [configure HTTP proxy](#configure-http-proxy)? Or maybe you need to [allow a user to run Docker commands](#allow-a-user-to-run-docker-commands)?

## Start Docker on boot

```sh
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

## Allow a user to run Docker commands

Add the user to the `docker` group.

```sh
sudo usermod -aG docker $USER
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

## Configure HTTP proxy

_From [this guide](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)_

Create systemd drop-in directory.

```sh
sudo mkdir -p /etc/systemd/system/docker.service.d
```

Create `/etc/systemd/system/docker.service.d/http-proxy.conf` and add the following configuration, modifying the values as appropriate.

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80"
Environment="HTTPS_PROXY=https://proxy.example.com:443"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
```

Flush changes, restart Docker service, and verify changes are applied.

```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl show --property=Environment docker
```

Test it works.

```sh
docker run hello-world
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

Add the `"experimental": "enabled"` key to the client configuration in `$HOME/.docker/config.json`. If this file doesn't already exist, you can use the following to create it:

```sh
mkdir $HOME/.docker
tee $HOME/.docker/config.json <<EOF
{
  "experimental": "enabled"
}
EOF
```

Check experimental features are enabled for both the server and client.

```sh
docker version
```

## References

* [https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html](https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html)
* [https://thenewstack.io/how-to-enable-docker-experimental-features-and-encrypt-your-login-credentials/](https://thenewstack.io/how-to-enable-docker-experimental-features-and-encrypt-your-login-credentials/)
* [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/)
