# Customize prompt
export PS1="\u@\h:\w \$ "
# Homebrew vars
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
# Wine
export PATH=/Applications/Wine\ Stable.app/Contents/Resources/wine/bin:$PATH
# Use current tty for GPG
export GPG_TTY=$(tty)
# Anaconda
export PATH=/usr/local/anaconda3/bin:$PATH
# Android SDK
export PATH=$HOME/Library/Android/sdk/platform-tools:$PATH
# Ipopt
export IPOPT_INCLUDE_DIRS=$HOME/Downloads/Ipopt-3.11.1-mac-osx-x86_64-gcc4.5.3/include
export IPOPT_LIBRARIES=$HOME/Downloads/Ipopt-3.11.1-mac-osx-x86_64-gcc4.5.3/lib
#export IPOPT_INCLUDE_DIRS=/usr/local/Cellar/ipopt/3.12.13_2/include
#export IPOPT_LIBRARIES=/usr/local/Cellar/ipopt/3.12.13_2/lib
# Other binaries
export PATH=$HOME/.local/bin:$PATH
# Terraform
export PATH="/usr/local/opt/terraform@0.11/bin:$PATH"
# Yarn
export PATH=$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH
# My scripts
export PATH=$HOME/projects/3ch01c.github.io/scripts:$PATH
#export PATH=$PATH:$HOME/projects/3ch01c/utils
# Set up proxy
#. proxy.sh
# Start Minikube
#. minikube.sh
# Docker Machine
#. start_docker_machine.sh