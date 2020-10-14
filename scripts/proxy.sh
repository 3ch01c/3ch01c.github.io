#!/bin/bash
# Set proxy environment variables

#http_proxy=$(findproxyforurl.sh) 
http_proxy=$1
if [[ $http_proxy == "" ]]; then
  unset proxy_pac_url
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
  unset no_proxy
  unset NO_PROXY
else
 export http_proxy=$http_proxy
 export HTTP_PROXY=$http_proxy
 export https_proxy=$http_proxy
 export HTTPS_PROXY=$https_proxy
 # Don't use proxy for the domain of the proxy server
 export no_proxy=127.0.0.1,localhost,$(echo "$http_proxy" | awk -F. '{print "."$2"."$3}' | awk -F: '{print $1}')
 export NO_PROXY=$no_proxy
fi
