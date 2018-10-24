# sysutils
A series of scripts meant to make working with servers easier.

# Installation

To installt these scripts, clone them to some place reasonable (/usr/share?), and then run `install.sh` as root. To uninstall, run `uninstall.sh` as root.

# Utilities

## reset-permissions

Resets permissions to a specified path to the default Linux permissions and changes ownership to the owner specified. By default, it will not make any changes to the system, You must specify the `--commit` argument in order to make the changes.

Example:

`reset-permissions /home/foo baruser --commit`