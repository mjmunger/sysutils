#!/usr/bin/env bash

sysutils_config() {
    if [ -z $2 ]; then
        echo "Argument missing."
        show_config_help
        exit 1
    fi

    case $2 in
        'hostname')
            config_hostname $@
        ;;
        'setup-server')
            setup_server $@
        ;;
    *)
        show_config_help
    ;;
    esac
}