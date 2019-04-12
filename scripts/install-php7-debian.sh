#!/usr/bin/env bash

install_php7_debian_packages() {
    apt update
    apt --assume-yes upgrade
    apt install ca-certificates apt-transport-https
    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
    echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
    apt update
    apt install --assume-yes php7.2
    apt install --assume-yes libapache2-mod-php7.2 php7.2 php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-gd php7.2-imap php7.2-intl php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php7.2-pspell php7.2-readline php7.2-recode php7.2-soap php7.2-sqlite3 php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip php-libsodium php-mcrypt php7.2-gmp
}