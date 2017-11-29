#! /usr/bin/env bash

set -e

cd "`dirname $0`"
mypath="`pwd`"
mydir="`basename $mypath`"
[ "$mydir" = '.installers' ] || die 2 "Bad location: $0"

. "$mypath"/.tools.sh

_ln () {
    local source=$1
    local target=$2
    [ "$target" != . ] || target="`basename $source`"
    [ -e "$target" ] || ln -s "$source" "$target" || die 1 "unable to make link for $target"
}

# create links for the y2j stuff
for t in j2y y2j yq; do
    _ln y2j.sh $t
done

cd .. || die 3 "unable to change directory"

# link .tools.sh
_ln .installers/.tools.sh .

for f in `ls .installers`; do
    target=`basename $f`
    _ln .installers/.base.sh $target
done
