# How to SSH via proxy

On the local machine, create a new host entry in `~/.ssh/config` for the remote
server.

``` text
Host REMOTE_SERVER
```

The `ProxyCommand` directive specifies the proxy server and the command to
execute from the proxy server (e.g., `ssh example.com`). To connect to a reverse
SSH tunnel from the proxy, the command would be something like `nc localhost
REMOTE_SERVER_PORT`.

``` text
    ProxyCommand ssh PROXY_SERVER COMMAND
```

The `Port` and `User` are of the _remote_ server, not the proxy server.

``` text
    Port REMOTE_SERVER_PORT
    User REMOTE_USER
```

If the proxy server and the remote server use different credentials, the
`ForwardAgent on` directive can be used to pass local credentials through the
proxy server in order to authenticate to the remote server. In this way, the
local private key does not have to be stored on the proxy server.

``` text
    ForwardAgent yes
```

The final command will look something like this:

``` text
Host example.com
    ProxyCommand ssh proxyexample.com 'ssh example.com'
    Port 22
    User me
    ForwardAgent yes
```