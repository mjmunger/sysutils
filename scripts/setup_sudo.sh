#!/usr/bin/env bash

setup_sudo() {
    echo -n "Modify / update sudoers to not require passwords for members of the sudo group..."
    #Modify / update sudoers to not require passwords for members of the sudo group.
    chmod +w /etc/sudoers
    sed -i 's/sudo.*ALL=(ALL:ALL)/\sudo    ALL=NOPASSWD:/g' /etc/sudoers
    chmod -w /etc/sudoers
    echo "[OK]"
}