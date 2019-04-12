#!/usr/bin/env bash

setup_user() {
    echo "Setting up user: $1..."
    PASS=`pwgen -cns 12 1`
    #Create the user as specified by the $1 argument.
    useradd -m $1
    usermod -s /bin/bash $1
    #add to the sudo group.
    usermod -a -G sudo $1
    echo "Setting password to: $PASS"
    echo "$1:$PASS" | chpasswd

    echo "Saving information to setup.log"
    echo $1 : $PASS >> setup.log

    if [ ! -d /home/$1/.ssh ]; then
        echo "Making directory: /home/$1/.ssh/"
        mkdir /home/$1/.ssh/
    fi

    download_install_key $1

    #Make sure .ssh exists.
    if [ ! -d /home/$1/.ssh/ ]; then
        mkdir -p /home/$1/.ssh/
    fi


    #Setup .bashrc for color and verbose copies, moves, and dels.
    sed -i 's/^# export/export/g' /home/$1/.bashrc
    sed -i 's/^# alias/alias/g' /home/$1/.bashrc
    sed -i 's/^# eval/eval/g' /home/$1/.bashrc
    sed -i 's/^-i/-v/g' /home/$1/.bashrc

    chown -R $1:$1 /home/$1
}