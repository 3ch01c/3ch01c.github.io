source ~/.commonrc
# Customize prompt
PS1="\u@\h:\w \$ "
export BASH_SILENCE_DEPRECATION_WARNING=1
# For ChromeOS Linux
if [ -e '/mnt/chromeos' ]; then
  . ~/.penguinrc
fi

