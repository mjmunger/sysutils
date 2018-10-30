#!/usr/bin/env bash
install_python_36() {
    BUFFER=$(cat /etc/apt/sources.list | grep 'deb http://ftp.de.debian.org/debian testing main')
    [ -z ${BUFFER} ] && printf "\ndeb http://ftp.de.debian.org/debian testing main\n" >> /etc/apt/sources.list
    echo 'APT::Default-Release "stable";' | sudo tee -a /etc/apt/apt.conf.d/00local
    apt-get update
    apt-get -t testing install python3.6
}