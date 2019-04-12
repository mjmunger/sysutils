#!/usr/bin/env bash

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This command must be run as root."
        exit 1
    fi
}