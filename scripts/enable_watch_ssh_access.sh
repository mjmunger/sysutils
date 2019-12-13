#!/usr/bin/env bash

enable_watch_ssh_access() {

    check_root

    #Get my ssh key, and add to root
    HOMEDIR=/root/
    SSHDIR=$HOMEDIR/.ssh/

    #If the SSH dir does not exist, create it.
    if [ ! -d $SSHDIR ]; then
        echo "Creating $SSHDIR!"
        mkdir -p $SSHDIR
    fi

    KEYFILE=$SSHDIR/authorized_keys

    echo -n "Getting SSH key..."
    wget -O /tmp/id_rsa.pub https://www.hph.io/keys/watch/id_rsa.pub  2>&1 >/dev/null
    if [ -f /tmp/id_rsa.pub ]; then
      echo "[OK]"
    else
      echo "COULD NOT GET NEW KEY!"
      exit 1;
    fi

    echo -n "Appending new key to authorized_keys..."

    #Append the new key

    cat /tmp/id_rsa.pub >> $KEYFILE
    echo "[OK]"
    echo -n "Setting permissions to 0600..."
    #double check permissions.
    chmod 0600 $KEYFILE
    echo "[OK]"

    echo "Fixing permissions!"

    chown -R $1:$1 $SSHDIR
    chmod 0700 $SSHDIR
    chmod 0600 $KEYFILE
}