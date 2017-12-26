#! /usr/bin/env bash

# Blindly assume this location...
. ~/bin/.installers/.tools.sh

mv -f ~/.setup/.env.tmp ~
envAdd () {
  echo "$@" >> ~/.env.tmp
}

# Do this before sourcing anything else so the files can be found in PATH
$HOME/bin/.installers/.makelinks.sh

# NOTE: env.tmp starts with stuff in the path already
export GOROOT=$HOME/usr/local/go # WARNING: Also hard-coded in env/bin/.installers/go!
envAdd export GOROOT=$GOROOT

envAdd pathadd $GOROOT/bin after

for p in x86_64-linux-gnu man-db; do
    LD_LIBRARY_PATH=$HOME/usr/lib/$p${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
done
export LD_LIBRARY_PATH
envAdd export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# perlbrew depends on this
#APTinstall libpipeline1 man-db

echo "Installing perlbrew.pl" # Do this now, so we can include it in .bashrc
wget -O - https://install.perlbrew.pl | bash
grep -v 'hash -r' ~/perl5/perlbrew/etc/bashrc > ~/.perlbrew.bashrc # hash -r complains because we have hashing disabled
envAdd 'source ~/.perl.env'
envAdd 'source ~/.perlbrew.bashrc'

mv -f ~/.env.tmp ~/.env.sh

# Some things take forever to install, so we pro-actively start that process
source ~/.env.sh
logdir=~/bin/.log
mkdir -p $logdir
[ -e ~/.nopre ] || for f in go sqitch aws; do
  log=$logdir/$f.log
  if ! [ -e $log ]; then
    echo "Installing $f in the background. Install log is available at $log"
    $f 2>&1 | timestamp > $log &
  fi
done

# vi: expandtab ts=2 sw=2
