#!/bin/sh

set -e

# We need to install Pyyaml before y2j, j2y or yq will work
pip install Pyyaml

[ -r y2j.tar.gz ] || wget -O y2j.tar.gz https://github.com/wildducktheories/y2j/archive/master.tar.gz
[ -d y2j-master ] || tar xf y2j.tar.gz
( y2j-master/y2j.sh installer $HOME/usr/bin || echo exit $? ) | /bin/sh
