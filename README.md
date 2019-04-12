# sysutils
A series of scripts meant to make working with servers easier.

# Installation

To install these scripts, clone them to some place reasonable (/usr/share?), and then run `install.sh` as root. To uninstall, run `uninstall.sh` as root.

# Utilities

## reset-permissions

Resets permissions to a specified path to the default Linux permissions and changes ownership to the owner specified. By default, it will not make any changes to the system, You must specify the `--commit` argument in order to make the changes.

Example:

`reset-permissions /home/foo baruser --commit`

## Setup server

Sets up Debian based servers with various common configurations. See its own help file for more information.

# Installers

The installer receipes are located in `scripts/installers` and have a specific format to allow them to be pluggable. They must be structured this way:

```
#!/usr/bin/env bash
# [COMMAND TAG]
# [DESCRIPTION]

run_installer() {
...install script goes here...
}
```

When the `sysutils install` command reads these files, it will do two things:
1. If there is *no* package specified, it will read the `scripts/install` directory and parse lines 2 and 3 to get the command tag and description, respectively.
1. If a command tag IS specified, the installer will look in `scripts/install` to see if a bash script with that tag exists. If it does, it will load it using `source`, and then execute the `run_installer` function._