#!/usr/bin/env bash
# certbot
# Install certbot for Debian 9 (stretch).

run_installer() {
    CERBOTLIST=/etc/apt/sources.list.d/certbot.list

    if [ ! -f ${CERBOTLIST} ]; then
        printf "\ndeb http://deb.debian.org/debian stretch-backports main" > ${CERBOTLIST}
    fi

    apt -y update
    apt -y upgrade
    apt -y install certbot python-certbot-apache -t stretch-backports
}