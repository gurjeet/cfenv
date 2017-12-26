# cfenv - a cloud foundry container for development work
cfenv creates a container in cloud foundry that is useful for doing development
or debug work. It provides a general-purpose environment that you can ssh into.
It also provides some useful utiity commands that are installed on first
execution.

## Configuration
cfenv uses two environment variables for configuration:

### `CHISEL_LOCAL_PORT`
This is the local port that the chisel tunnel will listen on for ssh requests
(default: 5022). If you want to have multiple cfenv environments running
simultaneously, you will need to set this variable and assign each environment
a unique local port.

### `CHISEL_REMOTE_PORT`
This is the port that the chisel server in cloud foundry will listen on.
Normally there is no need to change this from the default of 2022.

## Usage
All cfenv commands are accessed via the `cfe` shell script in the `bin`
directory. You might want to add `bin` to your `$PATH`.

Alternatively, if you're creating a shell script, you can source the file
returned via `cfe sourceFile`. That will add `CFE*` functions that correspond
to `cfe` commands. IE: instead of doing `cfe ssh`, you can do `CFEssh`. Note
that the script also adds some `_CFE*` functions.

## Commands
These are the commands available via `cfe`. Except where noted, all of these
commands will start the remote instance as well as the local tunnel if
necessary.

### `ssh`
Starts an `ssh` command connecting to the remote environment. This is equivalent to

```
ssh -p $CHISEL_LOCAL_PORT vcap@127.0.0.1 $@
```

### `scp`
Performs an scp TO the remote environment. Equivalent to

```
scp -P $CHISEL_LOCAL_PORT $@ vcap@127.0.0.1:
```

### `scpDest`
Similar to the `scp` command, except the first argument must be a destination to scp to, ie:

```
cfe scpDest Destination Source1 Source2
```

### `rsync`
Performs an rsync TO the remote environment. This is the same as the `scp`
command, just using rsync.

### `rsyncDest`
Performs an rsync TO the remote environment. This is the same as the `scpDest`
command, just using rsync.

### `drop` (or `dropTunnel`)
Removes the remote environment, via the `cf delete` command.

### `stop` (or `stopTunnel`)
Stops the local chisel tunnel, if running. This command does not affect the
remote environment.

### `restart` (or `restartTunnel`)
Restarts the remote environment (via the `cf restart` command). This is
essentially the same as doing a `cfe drop && cfe init`, but is faster.

### `reset`
Resets the remote environment. This means that the next time the `ssh` command
is run it will re-rsync the environment up to the cloud foundry instance.

## Other Commands
These are other commands that are exposed, though they are generally not
necessary.

### `init`
Initiallizes the cloud foundry environment if necessary.

### `initialized`
Returns a true (0) exit code if the remote environment has been initialized.
Starts the local tunnel as well as the remote environment if necessary.

### `dir`
Returns the directory that `cfenv` is checkout out at. Accepts an optional
argument for a relative directory inside the checkout, ie: `cfe dir env/bin`.

### `envDir`
Returns the location of the cfenv env directory. Equivalent to `cfe dir env`.

### `chiselDir`
Returns the location of the cfe chisel directectory.

### `sourceFile`
Returns the location of the file to source to load the cfenv shell functions.
