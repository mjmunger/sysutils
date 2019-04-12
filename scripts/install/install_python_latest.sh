#!/usr/bin/env bash
# python_latest
# Installs the latest version of Python from source.

run_installer() {
    apt update && apt upgrade -y
    apt install build-essential -y
    apt build-dep python
    apt install libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev -y
    apt install zlib1g -y
    cd /usr/src/
    wget https://www.python.org/ftp/python/3.7.1/Python-3.7.1.tar.xz
    tar xf Python-3.7.1.tar.xz
    cd /usr/src/Python-3.7.1/
    ./configure --enable-optimizations
    make
    make install
}