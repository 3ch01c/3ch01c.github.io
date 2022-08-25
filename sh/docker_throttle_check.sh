#!/bin/bash
# call it as <script> library/mysql blobs/sha256:2a72cbf407d67c7a7a76dd48e432091678e297140dce050ad5eccad918a9f8d6
# https://github.com/docker/hub-feedback/issues/1675#issuecomment-436316674
repo=$1
url=$2
token=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$repo:pull" | jq -r .token)
curl -v https://registry-1.docker.io/v2/$repo/$url -H "Authorization: Bearer $token" -L > /dev/null