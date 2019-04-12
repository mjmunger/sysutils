#!/usr/bin/env bash

setup_server() {
    case $3 in
        'php7deb' )
        check_root
        install_php7_debian_packages
        ;;
        'add-admin')
            add_admin $@
        ;;
        *)
            show_help_setup_server
        ;;
    esac
}