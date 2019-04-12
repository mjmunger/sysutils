#!/usr/bin/env bash

show_config_hostname_help() {
cat <<EOF

sysutil config hostname

    Sets the hostname for this server.

Syntax:

    sysutils config [hostname] [domain]

Example:

    To configure a server as foo.bar.org:

        hostname config foo bar.org

EOF
}

config_hostname() {

    if [ -z "$1" ] || [ -z "$2" ]; then
        show_config_hostname_help
        exit 1
    fi

    HOSTNAME=$1
    DOMAIN=$2
    FQDN=${HOSTNAME}.${DOMAIN}

    hostname ${HOSTNAME}
    echo "${HOSTNAME}" > /etc/hostname
    printf "\n 127.0.0.1     ${HOSTNAME} ${FQDN}" >> /etc/hosts

    echo "Log out and log back in to ensure this was configured properly."

}