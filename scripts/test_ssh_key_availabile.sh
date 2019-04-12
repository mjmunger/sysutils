#!/usr/bin/env bash

show_key_error() {
    USER=$1
    URL=$2
    cat <<EOF

    ERROR: There is no ssh key available for ${USER} at ${URL}.

    To add a user without an ssh key, you must use the --no-key option.

EOF
}

test_ssh_key_available() {
    USER=$1
    URL="https://hph.io/keys/${USER}/id_rsa.pub"

    curl --output /dev/null --silent --head --fail ${URL}
    if [ $? -ne 0 ]; then
        if [ "$2" != "--no-key" ]; then
            show_key_error ${USER} ${URL}
            exit 1
        fi
    fi
}