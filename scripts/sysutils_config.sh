#!/usr/bin/env bash

show_sysutils_config_help() {
    cat <<EOF

sysutils config

    This is a group of server administration scripts that help configure a server.

Syntax:

    sysutils config [command] [arg1, arg2, ...]

Available commands:

    checklist     Run the inital setup checklist for a Debian server.
    hostname      Set the hostname for this server
    setup-server  Setup this server using known good recipes.

Support and issues should be filed on github: https://github.com/mjmunger/sysutils

EOF
}

sysutils_config() {
    if [ -z $2 ]; then
        echo "Argument missing."
        show_sysutils_config_help
        exit 1
    fi

    case $2 in
        'checklist')
            run_checklist
        ;;
        'hostname')
            config_hostname $@
        ;;
        'setup-server')
            setup_server $@
        ;;
    *)
        show_sysutils_config_help
    ;;
    esac
}