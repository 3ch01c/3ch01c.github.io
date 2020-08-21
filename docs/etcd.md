# etcd

## Quick Start

Download and extract the `etcd` binaries to your `PATH`.

```sh
RELEASE="3.3.13"
PLATFORM="linux-amd64"
curl -fsSL https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-${PLATFORM}.tar.gz | tar xzvf -
sudo mv etcd-v${RELEASE}-${PLATFORM}/{etcd,etcdctl} /usr/local/bin
etcd --version
```

Create Etcd configuration and data directory.

```sh
sudo mkdir -p /var/lib/etcd/
sudo mkdir /etc/etcd
```

Create `etcd` system user.

```sh
sudo groupadd --system etcd
sudo useradd -s /sbin/nologin --system -g etcd etcd
```

Set `/var/lib/etcd/` directory ownership to `etcd` user.

```sh
sudo chown -R etcd:etcd /var/lib/etcd/
```

Create a new `systemd` service file for `etcd`.

```sh
sudo tee /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
Environment=ETCD_DATA_DIR=/var/lib/etcd
Environment=ETCD_NAME=%m
ExecStart=/usr/local/bin/etcd
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF
```

Reload `systemd` and start `etcd`.

```
sudo systemctl daemon-reload
sudo systemctl start etcd.service
```
