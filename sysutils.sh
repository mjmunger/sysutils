#!/usr/bin/env bash

usage() {
    cat <<EOF

Sysutils

    This is a group of server administration scripst that should make life easier.

Syntax:

    sysutils [command] [options]

Available commands:

    show     Show information about this installation.

             Available Options:

             version      Show the current version of sysutils.
             installpath  Show the installation path of sysutils.
             everything   Show everything on this list.

    update   Get the latest release. (requires root).

Support and issues should be filed on github: https://github.com/mjmunger/sysutils
EOF
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This command must be run as root."
        exit 1
    fi
}

show_version() {
    cd ${INSTALLDIR}
    VERSION=$(git describe --tags)
    echo "Your current version of sysutils is: ${VERSION}"
}

update_package() {
    cd ${INSTALLDIR}
    git pull
    show_version
}

show_install_path() {
    echo "Sysutils is installed in: ${INSTALLDIR}"
}

show_info() {
    echo ""
    case $1 in
        'installpath')
        show_install_path
        ;;
    'version')
        show_version
        ;;
    'everything')
        echo "Showing information for your sysutils installation"
        echo ""
        show_install_path
        show_version
        ;;
    *)
        usage
        ;;
    esac

    echo ""
}

INSTALLDIR=$(dirname $(readlink -f /usr/local/bin/reset-permissions))

case $1 in
    'update')
        check_root
        update_package
        ;;
    'show')
        show_info $2
        ;;
    *)
        usage
        ;;
esac