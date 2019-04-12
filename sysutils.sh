#!/usr/bin/env bash

INSTALLDIR=$(dirname $(readlink -f /usr/local/bin/reset-permissions))
SCRIPTSDIR=${INSTALLDIR}/scripts
PACKAGEINSTALLDIR=${SCRIPTSDIR}/install

for f in ${SCRIPTSDIR}/*;
do
    if [ "$1" == "--debug" ]
    then
        echo "Loading $f..."
    fi

    if [ -d $f ]; then
        continue
    fi
    source $f
done

usage() {
    cat <<EOF

Sysutils

    This is a group of server administration scripst that should make life easier.

Syntax:

    sysutils [command] [options]

Available commands:

    config   Run a configuration script
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

install_bacula() {
    apt update && apt --assume-yes upgrade
    apt install bacula bacula-common-mysql bacula-console bacula-client

}

list_packages() {
    cat <<EOF

Available packages to install:

  bacula-dir - Install bacula from Debian repos.
  bacula-fd  - Install bacula file director client (only).
  composer   - Install composer
  pyrpg      - Generate cryptographically secure random passwords with specified character sets, patterns, or lengths.
  python3    - Install Python using Debian packages


EOF
}

first_run_checklist() {
    echo "Enter the hostname for this computer"
    read HOSTNAME
    echo "Enter the domain for this computer"
    read DOMAIN
    echo ${HOSTNAME} > /etc/hostname
    hostname ${HOSTNAME}
    sed -i "s/changeme/${HOSTMANE}/g" /etc/hosts
    sed -i "s/example.com/${DOMAIN}/g" /etc/hosts
    MAC=$(ip addr | grep ether)
    echo "Mac address is: ${MAC}. Create the DHCP reservation now, and press enter. Or, type skip to skip this."
    read CHOICE
    if [ "${CHOICE}" != 'skip' ]; then
        dhclient -v
    fi
    prefer_ipv4
    disable_ipv6
    update_apt
    apt update
    apt --assume-yes upgrade
    apt-get install --assume-yes ntp
    harden_root_password
}

setup_auto_updates() {
    apt-get install --assume-yes unattended-upgrades apt-listchanges
    sed -i 's#//Unattended-Upgrade::Mail "root"#Unattended-Upgrade::Mail "root"#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable";#        "o=Debian,a=stable";#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable-updates";#        "o=Debian,a=stable-updates";#g' /etc/apt/apt.conf.d/50unattended-upgrades
}

clear_sources() {
    #Kill the original sources
    cat /dev/null > /etc/apt/sources.list
}

update_apt_jessie() {
    clear_sources
    echo -n "Updating APT to user sources as stated in https://wiki.debian.org/SourcesList..."

    #Add in sources as stated in https://wiki.debian.org/SourcesList

    echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
    echo "[OK]"
}

update_apt_stretch() {
    clear_sources

    cat > /etc/apt/sources.list <<-'EOF'
deb http://deb.debian.org/debian stretch main contrib non-free
deb-src http://deb.debian.org/debian stretch main contrib non-free

deb http://deb.debian.org/debian stretch-updates main contrib non-free
deb-src http://deb.debian.org/debian stretch-updates main contrib non-free

deb http://security.debian.org/debian-security/ stretch/updates main contrib non-free
deb-src http://security.debian.org/debian-security/ stretch/updates main contrib non-free
EOF

}

update_apt() {
    CODENAME=`lsb_release -c | awk '{ print $2 }'`

    echo "System codename detected as $CODENAME"
     case $CODENAME in
        'jessie')
            update_apt_jessie
            ;;
        'stretch')
            update_apt_stretch
            ;;
        * )
            error_out "$CODENAME not found. Cannot update apt sources."
    esac

}

prefer_ipv4() {
    sed -i 's/^#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/g' /etc/gai.conf
}

disable_ipv6() {
    cat >> /etc/sysctl.conf <<-'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.eth1.disable_ipv6 = 1
net.ipv6.conf.ppp0.disable_ipv6 = 1
net.ipv6.conf.tun0.disable_ipv6 = 1
EOF
    echo "You should reboot to ensure this is active and effective."
}

case $1 in
    'config')
        sysutils_config $@
    ;;
    'update')
        check_root
        update_package
        ;;
    'install')
        check_root
        install_package $2
        ;;
    'list' )
        list_installable_packages ${PACKAGEINSTALLDIR}
        ;;
    'show')
        show_info $2
        ;;
    'checklist')
        first_run_checklist
        ;;
    *)
        usage
        ;;
esac