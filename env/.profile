#echo .profile

# normal behavior of caching command locations breaks bin/.installers
set +h

[ -e $HOME/.real_user.env ] && . $HOME/.real_user.env

[ -e $HOME/.env.sh ] || $HOME/.setup/setup.sh
. $HOME/.env.sh

[ -e $HOME/.profile-original ] && . $HOME/.profile-original
