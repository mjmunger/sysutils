#!/usr/bin/env bash

show_config_help() {
    cat <<EOF

sysutils config

    This is a group of server administration scripts that help configure a server.

Syntax:

    sysutils config [command] [arg1, arg2, ...]

Available commands:

    hostname    Set the hostname for this server
    setup-server  Setup this server using known good recipes.

Support and issues should be filed on github: https://github.com/mjmunger/sysutils

EOF
}