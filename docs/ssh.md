# SSH

## ControlMaster

Here's a cool SSH trick I just learned. My tunnel to an Ollama server keeps getting disconnected even with `ServerAliveInterval` set and I have to use my Yubikey to reconnect. If you have a SSH connection that requires interactive login (e.g. Yubikey), you can use a feature called `ControlMaster` to authenticate once and piggyback future connections through it. The `ControlPersist` defines how long to keep the authenticated connection alive, e.g. `10h`. Here's my `~/.ssh/config`:

```
​Host pascal
  ControlMaster auto
  ControlPath ~/.ssh/controlmasters/%r@%h:%p
  ControlPersist 10h
  ServerAliveInterval 60
  ServerAliveCountMax 3

Host pascal-tunnel
  HostName pascal
  ControlMaster no
  ControlPath ~/.ssh/controlmasters/%r@%h:%p
  LocalForward 11435 localhost:11434
  ExitOnForwardFailure yes
```

Then you just log in once and it stores the session in `~/.ssh/controlmasters` for future use.

```
echoic@dev:~$ ssh -fN pascal
echoic@pascal's password:
echoic@dev:~$ ssh -O check pascal
Master running (pid=568140)
echoic@dev:~$ ssh -fN pascal-tunnel
echoic@dev:~$ curl -s http://localhost:11435/api/tags | head -c100
{"models":[{"name":"llama3:70b-instruct","model":"llama3:70b-instruct","modified_at":"2026-02-02T12:
```

If you want to close the session early:

```
echoic@dev:~$ ssh -O exit pascal
Exit request sent.
echoic@dev:~$ ssh -O check pascal
Control socket connect(/home/echoic/.ssh/controlmasters/echoic@pascal:22): No such file or directory 
```
