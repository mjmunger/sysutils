#!/usr/bin/env bash

show_help_add_admin() {
    cat <<EOF

Usage: sysutils setup-server add-admin [user]

EOF

}

add_admin() {
    USER=$4
    OPTION=$5
    if [ -z "${USER}" ]; then
        show_help_add_admin
        exit 1
    fi
    check_root
    test_ssh_key_available ${USER} ${OPTION}
    setup_user $@
}