# Do this before sourcing anything else so the files can be found in PATH
$HOME/bin/.installers/.makelinks.sh

[ -e $HOME/.profile-original ] && . $HOME/.profile-original
