[ -e $HOME/.bashrc-original ] && . $HOME/.bashrc-original

[ -e $HOME/.env.sh ] && . $HOME/.env.sh

for f in $HOME/.bashrc.d/*; do . $f; done
