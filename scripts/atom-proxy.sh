#!/bin/sh

printHelp () {
	echo "Usage: $0 HTTP_PROXY [HTTPS_PROXY]"
	exit 1
}

# parse command arguments
if [[ $# -eq 0 ]]; then
	printHelp
fi
HTTP_PROXY=$1
if [[ $# -eq 2 ]]; then
  HTTPS_PROXY=$2
fi

# get config path based on os
os=$(uname -a | cut -d' ' -f1)
if [[ os -eq "Darwin" ]]; then
  CONFIG_PATH="/Applications/Atom.app/Contents/Resources/app/apm/node_modules/atom-package-manager/.apmrc"
elif [[ os -eq "Linux" ]]; then
  CONFIG_PATH="~/.apmrc"
fi

echo "http-proxy = $HTTP_PROXY" > $CONFIG_PATH
if [[ -z ${HTTPS_PROXY+x} ]]; then
  echo "https-proxy = $HTTPS_PROXY" > $CONFIG_PATH
fi
