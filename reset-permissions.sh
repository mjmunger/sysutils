#!/usr/bin/env bash

check_root() {
    if [ $(whoami) != "root" ]; then
      echo "$0 should be run as root! You're not root. Magic 8 ball says: RTFM."
      usage
      exit 1
    fi
}

usage() {
    cat <<EOF

Reset Permissions

Sets default system permissions for a specified path, and fixes ownership.

Syntax: reset-permissions path [user] [commit]

Where:
    path is the path you want to reset permissions.
    user is the user who should own the path
    commit tells the system you really do want to commit your changes ot the file system.

    If no user is specified, the current user is assumed.

Examples:

    To change all the files in /home/foo/:

        reset-permissions /home/foo myuser --commit


Support and issues should be filed on github: https://github.com/mjmunger/sysutils
EOF
}

check_args() {
    if [ $1 -lt 1 ];
    then
        usage
        exit 1
    fi
}

error_out() {
    echo ""
    echo "ERROR: " $1
    echo ""
    exit 1
}

check_path() {
    if ! [ -d $1 ];
    then
        error_out "Path $1 does not exist."
        usage
    fi
}

help_hint() {
    echo ""
    echo 'type `./reset-permissions help` for command syntax and usage.'
    echo ""
}
check_user() {
    EXISTS=$(cat /etc/shadow | grep $1 | cut -d ':' -f1)
    if [ -z ${EXISTS} ]; then
        echo ""
        echo "ERROR: The specified user $1 does not exist!";
        help_hint
        exit 1
    fi
}

set_file_permissions() {
    [ "$3" == '--dryrun' ] && echo "DRY RUN!" || echo "Commiting changes to file system."

    echo "Setting ownership for $1 to $2:$2..."

    if [[ "$3" != "--commit" ]]; then
        echo "Nothing was changed in the file system. This was just a preview."
        echo "To commit your changes to the file system, use --commit as your final argument"
        return 0
    fi

    cd $1
    echo -n "Setting file ownership..."
    find . -type f -exec chown -R $2:$2 {} \; >/dev/null 2>&1
    echo "OK"
    echo -n "Setting directory ownership..."
    find . -type d -exec chown -R $2:$2 {} \; >/dev/null 2>&1
    echo "OK"

    echo -n "Setting file permissions..."
    find . -type f -exec mode 0644 {} \; >/dev/null 2>&1
    echo "OK"

    echo -n "Setting directory permissions..."
    find . -type d -exec mode 0755 {} \; >/dev/null 2>&1
    echo "OK"

}

check_root
check_args $#
check_path $1

TARGETPATH=$( [ "$1" == '.' ] && echo `pwd` || echo $1 )

USER=$(echo `whoami`)
if [ $# -ge 2 ]; then
    check_user $2
    USER=$2
fi
COMMIT=$( [[ $# -eq 3 ]] && [[ "$3" == '--commit' ]] && echo '--commit' || echo '--dryrun' )
set_file_permissions ${TARGETPATH} ${USER} ${COMMIT}