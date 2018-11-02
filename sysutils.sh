#!/usr/bin/env bash

usage() {
    cat <<EOF

Sysutils

    This is a group of server administration scripst that should make life easier.

Syntax:

    sysutils [command] [options]

Available commands:

    install  Install a package. (use list command to see what's available)
    list     List available packages.
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
    ./uninstall.sh
    ./install.sh
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

install_rpg() {
    apt build-dep python3
    apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

    cd /usr/src/
    git clone https://github.com/mjmunger/pyrpg.git
    cd pyrpg
    chmod +x install.sh
    ./install.sh
}

error_out() {
    echo $1
    echo ""
    usage
    exit 1
}

install_composer() {
    cd /usr/share/php/
    mkdir composer
    cd composer
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    cd /usr/local/bin/
    ln -s /usr/share/php/composer/composer.phar composer
    cd ~/
    composer --version
}

install_package() {

    [ -z $1 ] && error_out "You must specify a package to install"

    case $1 in
        'python3-deb')
            source ${SCRIPTSDIR}/install-python-36.sh
            install_python_36
            ;;
        'pyrpg')
            install_rpg
            ;;
        'composer')
            install_composer
            ;;
        *)
            error_out "Package $1 is not found."
            ;;
    esac
}

list_packages() {
    cat <<EOF

Available packages to install:

  pyrpg  - Generate cryptographically secure random passwords with specified character sets, patterns, or lengths.

EOF
}

INSTALLDIR=$(dirname $(readlink -f /usr/local/bin/reset-permissions))
SCRIPTSDIR=${INSTALLDIR}/scripts

case $1 in
    'update')
        check_root
        update_package
        ;;
    'install')
        check_root
        install_package $2
        ;;
    'list' )
        list_packages
        ;;
    'show')
        show_info $2
        ;;
    *)
        usage
        ;;
esac