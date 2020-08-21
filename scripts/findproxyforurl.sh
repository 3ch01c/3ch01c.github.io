#!/bin/bash
# Find HTTP proxy URL.
# Dependencies:
# * nodejs
# * [node-pac-resolver](https://github.com/TooTallNate/node-pac-resolver)
PLATFORM=$(uname -s)
if [[ "$PLATFORM" == "Darwin" ]]; then
  export proxy_pac_url=$(scutil --proxy | awk '/ProxyAutoConfigURLString/ { proxy_pac_url = $3; } END { print proxy_pac_url; }')
else
  echo "This script doesn't support $PLATFORM yet."
  exit 1
fi
curl -fsSL $proxy_pac_url -o proxy.pac &> /dev/null
if [[ $? == 0 ]]; then
  # npm i -g pac-resolver &> /dev/null # this won't work if proxy isn't set correctly
  http_proxy=$(node -e "var fs = require('fs'); var pac = require('pac-resolver'); var FindProxyForURL = pac(fs.readFileSync('proxy.pac')); FindProxyForURL('http://google.com/').then((res) => { console.log(res);});" | awk '/PROXY/ { proxyurl = $2; } END { print proxyurl; }' | tr -d ';')
  echo "$http_proxy"
fi
