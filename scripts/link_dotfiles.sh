#!/bin/bash
# Get directory of this script so relative paths work
PROJECTROOT=$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)/..")
# Link all the dotfiles
find $PROJECTROOT/dotfiles -name ".*" -maxdepth 1 -exec ln -sv {} ~/ \;