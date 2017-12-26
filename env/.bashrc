#echo `date`: "$0 $@" >> $HOME/.rclog

[ -e $HOME/.bashrc-original ] && . $HOME/.bashrc-original

[ -e $HOME/.env.sh ] && . $HOME/.env.sh

[ -e $HOME/.bashrc.d/* ] && for f in $HOME/.bashrc.d/*; do . $f; done
