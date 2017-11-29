# normal behavior of caching command locations breaks bin/.installers
set +h

[ -e $HOME/.env.sh ] || $HOME/.setup/setup.sh
. $HOME/.env.sh

[ -e $HOME/.profile-original ] && . $HOME/.profile-original
