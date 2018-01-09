debug () (
  limit=${DEBUG:-0}
  level=$1
  shift
  if [ $level -le $limit ]; then
    echo "$@" >&2
  fi
)

die() {
  rc=$1
  shift
  echo "$@" >&2
  exit $rc
}

Download() {
  local target="$1"
  shift

  if ! ls $HOME/.downloads/${target}* 2>/dev/null; then
    echo "Downloading $target"
    debug 1 wget "$@"
    # Download into a work directory, then do a (presumably atomic) mv. This
    # prevents issues with failed downloads. For some odd reason mv fails when
    # DEBUG > 0, so we force it to 0 for that command.
    mkdir -p $HOME/.downloads/work &&
      ( cd $HOME/.downloads/work && rm -f "${target}"* && wget "$@" && DEBUG=0 mv "${target}"* .. ) ||
      die $? "error downloading $target"
  fi
}

APTdownload () {
  local target="$1"
  shift

  # assumes that the .deb's always start with the name of the package
  if ! ls $HOME/.downloads/${target}* 2>/dev/null; then
    echo "Downloading $1"
    mkdir -p ~/.downloads &&
      ( cd $HOME/.downloads && apt-get download $1 ) ||
      die $? "error downloading $1"
  fi
}

APTinstall () {
  for p in "$@"; do
    APTdownload "$p"
    echo "Installing $p"
    ( cd /tmp &&
      rm -f data.tar.* &&
      ar x $HOME/.downloads/${p}* &&
      tar xf data.tar.* --directory $HOME
    ) || die $? "unable to install $p"
  done
}

# vi: expandtab ts=2 sw=2
