# Homebrew vars
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
export PATH="/usr/local/sbin:$PATH"
# GPG
export GPG_TTY=$(tty)
# If you need to have openjdk@8 first in your PATH, run:
export PATH="/home/me/.linuxbrew/opt/openjdk@8/bin:$PATH"
# For compilers to find openjdk@8 you may need to set:
export CPPFLAGS="-I/home/me/.linuxbrew/opt/openjdk@8/include"
# Anaconda
export PATH="/usr/local/anaconda3/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# Google Cloud SDK
export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"
if [[ $SHELL == "/bin/bash" ]]; then
  if [ -e "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]; then
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
  fi
elif [[ $SHELL == "/bin/zsh" ]]; then
  if [ -e "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  fi
fi
# Android SDK
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
# Ipopt
export IPOPT_INCLUDE_DIRS="$HOME/Downloads/Ipopt-3.11.1-mac-osx-x86_64-gcc4.5.3/include"
export IPOPT_LIBRARIES="$HOME/Downloads/Ipopt-3.11.1-mac-osx-x86_64-gcc4.5.3/lib"
#export IPOPT_INCLUDE_DIRS="/usr/local/Cellar/ipopt/3.12.13_2/include"
#export IPOPT_LIBRARIES="/usr/local/Cellar/ipopt/3.12.13_2/lib"
# Other binaries
export PATH="$HOME/.local/bin:$PATH"
# Terraform
export PATH="/usr/local/opt/terraform@0.11/bin:$PATH"
# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# postgres operator
export PATH=$HOME/.pgo/pgo:$PATH
export PGOUSER=$HOME/.pgo/pgo/pgouser
export PGO_CA_CERT=$HOME/.pgo/pgo/client.crt
export PGO_CLIENT_CERT=$HOME/.pgo/pgo/client.crt
export PGO_CLIENT_KEY=$HOME/.pgo/pgo/client.key
export PGO_APISERVER_URL='https://127.0.0.1:8443'
export PGO_NAMESPACE=pgo
# My scripts
export PATH="$HOME/Projects/3ch01c.github.io/sh:$PATH"
# Set up proxy
#. proxy.sh
# Set up Minikube
#. minikube.sh
# Set up Docker Machine
#. start_docker_machine.sh
