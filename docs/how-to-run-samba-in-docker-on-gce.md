# How to run Samba in Docker on Google Compute Engine instance

## Configure the firewall

1. Go to [Firewall Rules](https://console.cloud.google.com/networking/firewalls).
2. Click _Create Firewall Rule_.
    * Name: default-allow-smb
    * Target tags: smb-server
    * Source IP ranges: 0.0.0.0/0
    * Specified protocols and ports: tcp:445
    * Click _Create_.
3. Add `smb-server` tag to your GCE instance
    
## Configure the Docker instance

Thanks @stanback for [this awesome Samba container](https://hub.docker.com/r/stanback/alpine-samba) making this all possible. Just follow the instructions on the container page to configure it up. Here's what my `smb.conf` file looks like (I use the username `me` instead `carol`.):
```
[global]
  workgroup = WORKGROUP
  server string = %h server (Samba, Alpine)
  security = user
  map to guest = Bad User
  encrypt passwords = yes
  load printers = no
  printing = bsd
  printcap name = /dev/null
  disable spoolss = yes
  disable netbios = yes
  server role = standalone
  server services = -dns, -nbt
  smb ports = 445
  ;name resolve order = hosts
  ;log level = 3
  create mask = 0664
  directory mask = 0775
  veto files = /.DS_Store/
  nt acl support = no
  inherit acls = yes
  ea support = yes
  vfs objects = catia fruit streams_xattr recycle
  acl_xattr:ignore system acls = yes
  recycle:repository = .recycle
  recycle:keeptree = yes
  recycle:versions = yes

[projects]
  path = /shares/projects
  comment = Projects
  browseable = yes
  writable = yes
  valid users = me

[public]
  path = /shares/public
  comment = Public
  browseable = yes
  read only = yes
  write list = me
  guest ok = yes
```
And here's what my `docker-compose.yml` looks like:
```
version: "3.7"
services:
  samba:
    container_name: samba
    image: stanback/alpine-samba
    ports:
      - "445:445"
    volumes:
      - $PWD/smb.conf:/etc/samba/smb.conf
      - $PWD/shares/public:/shares/public
      - $PWD/shares/projects:/shares/projects
    restart: always
```
Start it up.
```
docker-compose up
```
And set up the Samba user.
```
docker exec -it samba adduser -s /sbin/nologin -h /home/samba -H -D me
docker exec -it samba smbpasswd -a me
```
Now you should be able to mount it with your SMB client!