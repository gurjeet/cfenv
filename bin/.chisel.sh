#
# HEADS UP!
#
# This file is meant to allow other users to source it! That means EVERYTHING
# in this file should start with either CFE or _CFE!
#
# HEADS UP!
#

# TODO: Add support for CFE_CHISEL_*
CHISEL_LOCAL_PORT=${CHISEL_LOCAL_PORT:=5022}
CHISEL_REMOTE_PORT=${CHISEL_REMOTE_PORT:=2022}
libload debug.sh die.sh

CFEssh() {
  CFEinit && _CFEssh $@
  debug 99 "CFEssh done"
}

CFEscp() ( CFEscpDest '' "$@" )
CFEscpDest() {
  CFEinit && _CFEscpDest "$@"
  debug 99 "CFEscpDest done"
}

# s/scp/rsync/g

CFErsync() ( CFErsyncDest '' "$@" )
CFErsyncDest() {
  CFEinit && _CFErsyncDest "$@"
  debug 99 "CFErsyncDest done"
}

# Reset the cfe environment by forcing it to re-sync
CFEreset() {
  # We don't need the full environment, but we do at least need the tunnel to
  # be up. So run CFEinitialized and toss the result.
  CFEinitialized || true
  _CFEssh 'bin/cfeReset >/dev/null'
  echo 'Environment will re-sync on next connection. EXISTING CONNECTIONS MUST EXIT.'
}

CFEdrop() ( CFEdropTunnel )
CFEdropTunnel() (
  $(CFEchiselDir)/tunnel drop
)

CFEstop() ( CFEstopTunnel )
CFEstopTunnel() (
  $(CFEchiselDir)/tunnel stop
)

CFErestart() ( CFErestartTunnel )
CFErestartTunnel() (
  $(CFEchiselDir)/tunnel restart
)


CFEinit() (
  if ! CFEinitialized; then
    echo "Initializing cfenv"

    set -e # Die on error

    # We know the tunnel is up at this point, so use the internal connection commands

    # Move the current .bashrc out of the way
    _CFEssh "[ -e .profile-original ] || mv .profile .profile-original; [ -e .bashrc-original ] || mv .bashrc .bashrc-original; echo 'export REAL_USER=$USER'>.real_user.env"

    # rsync the environment over
    d="$(CFEenvDir)" && cd "$d" && _CFErsyncDest '' -avP --relative .

    # Fire up the background setup tasks
    _CFEssh . .profile
  fi
)

# You probably want CFEssh instead...
_CFEssh () {
  # If you change this then fix the loop in CFEinitialized as well!
  _CFErun ssh -p $CHISEL_LOCAL_PORT vcap@127.0.0.1 $@
}

# You probably want CFEscp instead...
_CFEscpDest () {
  [ $# -ge 1 ] || die 1 "must specify destination (HINT: maybe you want scp instead of scpDest?)"
  local d="$1"
  shift
  _CFErun scp -P $CHISEL_LOCAL_PORT $@ vcap@127.0.0.1:"$d"
}

# You probably want CFErsync instead...
_CFErsyncDest () {
  [ $# -ge 1 ] || die 1 "must specify destination (HINT: maybe you want rsync instead of rsyncDest?)"
  local d="$1"
  shift
  _CFErun rsync -e "ssh -p $CHISEL_LOCAL_PORT" $@ vcap@127.0.0.1:"$d" || die $? "unable to rsync"
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
  local t rc=0
  [ $DEBUG -lt 9 ] || t='time '

  debug 6 "running $t$cmd $@"
  $t "$cmd" "$@" || rc=$?
  debug 9 "$cmd returned $rc"
  return $rc
}

_CFEstartTunnel () (
  local i=0 maxTries=10

  # Start the tunnel
  # TODO: allow user to specify options
  $(CFEchiselDir)/tunnel || die $? "unable to start tunnel"

  # We need to wait at least until we see that the port is up...
  until CFEportIsListening; do
    [ $i -le $maxTries ] || die 2 "ABORTED; tunnel failed to open."
    [ $i -gt 0 ] || echo -n "Waiting for tunnel to open ..."
    i=$((i+1))
    echo -n .
    sleep 1
  done
  [ $i -eq 0 ] || echo ' done!'

  # But even then, it can take a bit for the connection to become available.
  local i=0
  until _CFEssh 'true' 2>/dev/null; do
    [ $i -le $maxTries ] || break
    [ $i -gt 0 ] || echo -n "Waiting for ssh connection to become available ..."
    i=$((i+1))
    echo -n .
    sleep 1
  done
  if [ $i -ge $maxTries ]; then
    # run the command one last time without routing STDERR to /dev/null
    _CFEssh 'true' || die 2 "ABORTED; ssh was unable to connect"
  fi
  [ $i -eq 0 ] || echo ' done!'

  rc=0
  _CFEssh '[ -e $HOME/.cfe ]' || rc=$?

  if [[ $rc -eq 255 ]]; then
    die $rc "unable to connect to tunnel"
  fi
)

CFEinitialized () { # No subprocess so we can actually exit on error
  # connecting is relatively slow, so we optimize for the tunnel already being
  # up, and then check the return code.
  rc=0
  _CFEssh '[ -e $HOME/.cfe ]' || rc=$?
  
  # 255 means ssh itself failed, so attempt tunnel setup and then try again
  if [[ $rc -eq 255 ]]; then
    _CFEstartTunnel || exit $?

    # And re-run...
    _CFEssh '[ -e $HOME/.cfe ]' || rc=$?
  fi

  return $rc
}

CFEdir () {
  # Note that this will blow up on a symlink...
  local functionScript=$(CFEsourceFile)
  ( cd $(dirname $functionScript)/../$1 && pwd ) || die $? "unable to find CFE directory"
}

CFEenvDir() {
  CFEdir env
}


CFEchiselDir () {
  CFEdir submodules/src/github.com/jpillora/chisel
}

CFEsourceFile () {
  echo $BASH_SOURCE
}

# vi: expandtab ts=2 sw=2
