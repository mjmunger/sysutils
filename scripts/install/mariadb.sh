#!/usr/bin/env bash
# mariadb
# Installs MariaDB and the HPH MySQL backup and restore tools.

install_mysql_brtools() {
    cd /usr/src/
    git clone https://git.highpoweredhelp.com:8443/michael/mysql-brtools.git
    cd mysql-brtools
    ./setup
}

run_installer() {
    echo "Installing MariaDB..."
    apt update
    apt upgrade --assume-yes
    apt install mariadb-client mariadb-server
    install_mysql_brtools
    echo "Install complete."
}