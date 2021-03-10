#!/bin/bash
# Update docker-machine
#brew upgrade docker-machine
# Delete old docker-machine
#docker-machine delete
# Start docker-machine
docker-machine start --cpus 8 --memory 8192 --driver virtualbox
# Add docker-machine env vars
eval $(docker-machine docker-env)
# Add docker-machine IP to no_proxy
if [ ! -z ${no_proxy+x} ]; then
  export no_proxy=$no_proxy,$(docker-machine ip)
  export NO_PROXY=$no_proxy
fi