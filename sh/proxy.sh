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
  unset VAGRANT_HTTP_PROXY
  unset VAGRANT_HTTPS_PROXY
  unset VAGRANT_NO_PROXY
else
  export http_proxy=$http_proxy
  export HTTP_PROXY=$http_proxy
  export https_proxy=$http_proxy
  export HTTPS_PROXY=$https_proxy
  export no_proxy=127.0.0.1,localhost
  # Private subnets for programs that support it
  export no_proxy=${no_proxy},10.0.0.8/16,172.16.0.0/12,192.168.0.0/16
  # Don't use proxy for the domain of the proxy server
  export no_proxy=${no_proxy},$(echo "$http_proxy" | awk -F. '{print "."$2"."$3}' | awk -F: '{print $1}')
  # Don't use proxy for "internal" domain, e.g. kubernetes.docker.internal, minikube.internal, etc.
  export no_proxy=${no_proxy},.internal
  export NO_PROXY=$no_proxy
  export VAGRANT_HTTP_PROXY=$http_proxy
  export VAGRANT_HTTPS_PROXY=$https_proxy
  export VAGRANT_NO_PROXY=$no_proxy
fi
