# Customize prompt
export PS1="\u@\h:\w \$ "
# For ChromeOS Linux
if [ -e '/mnt/chromeos' ]; then
  . ~/.penguin.bashrc
fi
. ~/.exports.sh

