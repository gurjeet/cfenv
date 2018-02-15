#! /usr/bin/env bash

set -e +h

savedir=`pwd`
scriptdir=$(dirname $(pwd)/$0)

. `dirname $0`/.tools.sh

target=`basename $0`

echo "$target is not yet installed; attempting to install" >&2

[ "`basename $scriptdir`" != '.installers' ] || die 2 "Bad install location '$scriptdir'"
instdir="$scriptdir/.installers"
[ -d "$instdir" ] || die 2 "could not find .installers directory"

installer="$instdir/$target"
[ -x "$installer" ] || die 2 "installer '$installer' does not exist or is not executable"

# Before trying to run anything, make certain this directory is at the
# beginning of PATH. We do this to ensure installers pick up our stuff, not
# some random system thing. Also need to ensure we've picked up the path that
# prepper setup (if it's finished already)
[ ! -r ~/.env.sh ] || . ~/.env.sh
export PATH="$scriptdir:$PATH"

# Install
mkdir -p ~/.downloads || exit 2
cd ~/.downloads || exit 2
"$installer" >&2 || die 1 "error while installing $target"

# Get location of newly installed code before we remove the link we were called from
new=`which -a $target | grep -v $0 | grep "$HOME" | head -n1`
if [ -x "$new" ]; then
  rm -f $0 # it's possible the file was already removed
  debug 2 "running $new $@ from $savedir"
  cd "$savedir"
  "$new" "$@"
else
  echo "Newly found command '$new' is not executable" >&2
  exit 1
fi

# vi: expandtab ts=2 sw=2
