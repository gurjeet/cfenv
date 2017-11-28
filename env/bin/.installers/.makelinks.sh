#!/bin/sh

die() {
    rc=$1
    shift
    echo "$@" >&2
    exit $rc
}

cd "`dirname $0`"
mypath="`pwd`"
mydir="`basename $mypath`"
[ "$mydir" = '.installers' ] || die 2 "Bad location: $0"

# First, create links for the y2j stuff
for t in j2y y2j yq; do
    [ -e "$t" ] || ln -s y2j.sh $t
done

cd .. || die 3 "unable to change directory"

for f in `ls .installers`; do
    target=`basename $f`
    [ -e "$target" ] || ln -s .installers/.base.sh $target || die 1 "unable to make link for $target"
done
