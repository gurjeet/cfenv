CHISEL_LOCAL_PORT=${CHISEL_LOCAL_PORT:=5022}
CHISEL_REMOTE_PORT=${CHISEL_REMOTE_PORT:=2022}
libload debug.sh die.sh

CFEssh() {
  CFEinit && _CFEssh $@
  debug 99 "CFEssh done"
}

CFErsync() {
  CFEinit && _CFErsync $@
}

# returns true if the specified port is listening. NOTE: this will not verify that the tunnel enpoint is up!
CFEportIsListening () {
  # This will attempt to connect to 127.0.0.1 <port>, closing the connection immediately if successful
  if nc 127.0.0.1 $CHISEL_LOCAL_PORT < /dev/null; then
    debug 2 "able to connect to $CHISEL_LOCAL_PORT"
    return 0
  else
    debug 2 "UNABLE to connect to $CHISEL_LOCAL_PORT"
    return 1
  fi
}

_CFErun () {
  local cmd="$1"
  shift
  local t
  [ $DEBUG -lt 9 ] || t='time '

  debug 6 "running $t$cmd $@"
  $t "$cmd" "$@"
}

# You probably want CFEssh instead...
_CFEssh () {
  _CFErun ssh -p $CHISEL_LOCAL_PORT vcap@127.0.0.1 $@
}

# You probably want CFErsync instead...
_CFErsync () {
  _CFErun rsync -e "ssh -p $CHISEL_LOCAL_PORT" $@ vcap@127.0.0.1: || die $? "unable to rsync"
}


CFEinitialized () (
  # connecting is relatively slow, so we optimize for the tunnel already being
  # up, and then check the return code.
  rc=0
  _CFEssh '[ -e $HOME/.cfe ]' || rc=$?
  
  # 255 means ssh itself failed, so attempt tunnel setup and then try again
  if [[ $rc -eq 255 ]]; then
    $(CFEchiselDir)/tunnel || die $? "unable to start tunnel"
    _CFEssh '[ -e $HOME/.cfe ]' || rc=$?

    if [[ $rc -eq 255 ]]; then
      die $rc "unable to connect to tunnel"
    fi
  fi

  return $rc
)

CFEinit() (
  if ! CFEinitialized; then
    echo "Initializing cfenv"

    set -e # Die on error

    # We know the tunnel is up at this point, so use the internal connection commands

    # Move the current .bashrc out of the way
    _CFEssh '[ -e .profile-original ] || mv .profile .profile-original; [ -e .bashrc-original ] || mv .bashrc .bashrc-original'

    # rsync the environment over
    d="$(CFEenvDir)" && cd "$d" && _CFErsync -avP --relative .
  fi
)

CFEdir () {
  # Note that this will blow up on a symlink...
  functionScript=$BASH_SOURCE
  ( cd $(dirname $functionScript)/../$1 && pwd ) || die $? "unable to find CFE directory"
}

CFEenvDir() {
  CFEdir env
}


CFEchiselDir () {
  CFEdir submodules/src/github.com/jpillora/chisel
}

# vi: expandtab ts=2 sw=2
