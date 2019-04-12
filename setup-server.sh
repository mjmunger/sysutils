#!/usr/bin/env bash
# Absolute minimum for getting this to work is:
# apt-get update && apt-get --assume-yes install vim
# Then, copy / paste this into a file called setup-server.

# Checks to see if a dependency is installed by using the whcih command. If
# the return value from the which command is 0 (zero), then we assume that the
# item is not installed because the string length of the path to an item can
# never be zero.
#
# Usage: check_dependency someprogram

check_dependency() {
  echo -n "Checking for $1..."

  TEST=`which $1`
  EXISTS=${#TEST}

  if [ ${EXISTS} -gt 0 ]; then
    echo "[OK]"
  else
    echo "[FAILED]"
    echo "You need to install $1 before proceeding."
    exit 1
  fi
}

error_out() {
    echo "================================================================================"
    echo "Error: $1"
    echo "================================================================================"
    exit 1
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

install_base_packages() {
    echo "Installing base packages..."
    apt-get --assume-yes update
    apt-get --assume-yes upgrade

    #System stuff
    apt-get --assume-yes openssh-server

    #Network stuff
    apt-get --assume-yes curl wget rsync lynx

    #Utils
    apt-get --assume-yes ipcalc pwgen sudo htop chpasswd aptitude

    #Dev
    apt-get --assume-yes install vim git cmake libzip-dev libsodium-dev lvm2 unattended-upgrades curl

    #Security
    apt-get install --assume-yes fail2ban
    echo "Base packages installed."
}

install_mysql() {
    echo "Installing MySQL..."
    echo "Downloading the apt repsitory deb..."
    cd /tmp/
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.3-1_all.deb
    dpkg -i mysql-apt-config_0.8.3-1_all.deb
    apt-get update
    apt-get --assume-yes install mysql-server mysql-client
    mysql_upgrade
    install_mysql_brtools
    echo "MySQL Installed"
}

install_mariadb() {
    echo "Installing MariaDB..."
    apt update
    apt upgrade --assume-yes
    apt install mariadb-client mariadb-server
    install_mysql_brtools
    echo "Install complete."
}

install_mysql_brtools() {
    cd /usr/src/
    git clone https://git.highpoweredhelp.com:8443/michael/mysql-brtools.git
    cd mysql-brtools
    ./setup
}

install_php7() {
    echo "Installing PHP 7"
    apt-get update
    apt-get --assume-yes upgrade
    apt-get --assume-yes build-dep php5
    cd /usr/src/
    git clone https://github.com/php/php-src.git
    cd php-src
    check checkout tags/php-7.1.3
    wget https://raw.githubusercontent.com/mjmunger/php-ant/master/php/config-compile.sh
    chmod +x config-compile.sh
    ./config-compile.sh $2
    echo "Done. I emailed you about it."
}

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

install_lamp_stack() {
        CODENAME=`lsb_release -c | awk '{ print $2 }'`

    echo "System codename detected as $CODENAME"
     case $CODENAME in
        'jessie')
            install_lamp_stack_jessie
            ;;
        'stretch')
            install_lamp_stack_stretch
            ;;
        * )
            error_out "$CODENAME not found. Cannot update apt sources."
    esac

        echo "LAMP stack installed."
}

install_lamp_stack_stretch() {
    echo "Installing default LAMP stack for Stretch..."
    install_mariadb
    install_apache2
    install_php7_debian_packages
}

install_lamp_stack_jessie() {
    echo "Installing default LAMP stack for Jessie..."
    #Install LAMP Stack
    apt-get --assume-yes install php5 php5-cli php5-common php5-curl php5-dev php5-exactimage php5-gd php5-geoip php5-imagick php5-imap php5-json php5-ldap php5-mcrypt php5-memcache php5-memcached php5-mhash php5-mysqlnd php5-oauth php5-pecl-http php5-pecl-http-dev php5-readline php5-sasl php5-sqlite

    #Install itk AFTER LAMP stack because otherwise worker takes priority.
    apt-get --assume-yes install apache2-mpm-itk
}


install_mariadb() {
 echo "Installing MariaDB (drop-in replacement for MySQL)..."
 apt install --assume-yes dbconfig-common libdbd-mysql-perl libmariadbclient18 mariadb-client mariadb-client-10.1 mariadb-client-core-10.1 mariadb-common mariadb-server mariadb-server-10.1 mariadb-server-core-10.1

}

install_apache() {
    echo "Installing Apache..."
    apt install --assume-yes apache2 apache2-bin apache2-data apache2-utils libapache2-mod-dnssd libapache2-mod-fcgid

    #Install itk AFTER LAMP stack because otherwise worker takes priority.
    apt install --assume-yes libapache2-mpm-itk

    a2enmod ssl rewrite headers
    systemctl restart apache2
}

install_imagemagick() {
        #Sometimes, autoconf cannot be found by Perl and make because it's looking in the wrong place. So, symlink that.
        [ -d /usr/local/share/autoconf ] || ln -s /usr/share/autoconf/ /usr/local/share/autoconf

        echo "Preparing, compiling, and installing ImageMagick..."
        apt-get --assume-yes build-dep imagemagick
        cd /usr/src/
        git clone https://github.com/ImageMagick/ImageMagick.git
        cd ImageMagick
        git checkout 7.0.3-10

        ./configure
        make
        make install
        ldconfig /usr/local/lib
        make check
}

install_bacula() {
    echo "Preparing, compiling, and installing Bacula..."
    apt-get --assume-yes build-dep bacula
    cd /usr/src/

    git clone http://git.bacula.org/bacula.git
    cd bacula/bacula
    git checkout Release-7.4.4

    make distclean
    CFLAGS="-g -Wall"
    ./configure \
    --with-mysql \
    --with-readline=/usr/include/readline \
    --with-pid-dir=/opt/bacula/working \
    --with-subsys-dir=/opt/bacula/working \
    --with-working-dir=/opt/bacula/working \
    --with-smtp-host=localhost

    make
    make install
    make install-autostart-fd

    echo "Bacula setup complete. If you installed this on a directory, run make install-autostart to install all init scripts!"
}

install_mail_server() {
    echo "Installing mail server stuff..."
    apt-get install --assume-yes dovecot dovecot-lmtpd dovecot-mysql postfix
    echo "Mail servers postfix and dovecot installed, but you need to configure it."
}

compile_php() {
    apt-get --assume-yes build-dep php5
    #TODO: Insert stuff to compile PHP here.
}

install_certbot() {
    echo "deb http://ftp.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/certbot.list
    apt update
    apt --assume-yes upgrade
    apt-get install --assume-yes python-certbot-apache -t stretch-backports
    echo "Certbot installation complete."
}

setup_sudo() {
    echo -n "Modify / update sudoers to not require passwords for members of the sudo group..."
    #Modify / update sudoers to not require passwords for members of the sudo group.
    chmod +w /etc/sudoers
    sed -i 's/sudo.*ALL=(ALL:ALL)/\sudo    ALL=NOPASSWD:/g' /etc/sudoers
    chmod -w /etc/sudoers
    echo "[OK]"
}

download_install_key() {
    #Get my ssh key, and add to root
    HOMEDIR=`eval echo ~$1`
    SSHDIR=$HOMEDIR/.ssh/

    #If the SSH dir does not exist, create it.
    if [ ! -d $SSHDIR ]; then
        echo "Creating $SSHDIR!"
        mkdir -p $SSHDIR
    fi

    KEYFILE=$SSHDIR/authorized_keys

    echo -n "Getting SSH key..."
    wget -O /tmp/id_rsa.pub https://www.highpoweredhelp.com/keys/$1/id_rsa.pub  2>&1 >/dev/null
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

setup_server() {
    update_apt
    install_base_packages
    install_lamp_stack
    install_bacula
    install_mail_server
    echo "Thank you for flying quick setup airways. We hope you enjoyed your journey."
    echo ""
    echo "Please add users now by using setup --add-admin [user]. NOTE: These users WILL have root access via sudo! If you just want to setup users "
    echo "Done."
}

install_tinc() {

    apt-get install tinc
    cd /etc/
    tar cf tinc.original.tar /etc/tinc/
    rm -vfr /etc/tinc/
    if [ -f tinc.tar.xz ]; then
        echo "Removing old version of tinc.tar.xz"
        rm -v tinc.tar.xz
    fi
    wget https://www.highpoweredhelp.com/tinc.tar.xz
    tar xf tinc.tar.xz
    cd /etc/tinc/
    tincd -n webservices -K
    cd webservices
    $HOSTNAME=`hostname`
    echo "Enter this computer's name ($HOSTNAME)"
    read COMPUTERNAME
    if [ "${#COMPUTERNAME}" == "0" ]; then
        COMPUTERNAME="$HOSTNAME"
    fi

    echo "Using $COMPUTERNAME..."
    sed -i "s/\%NAME\%/$COMPUTERNAME/g" tinc.conf

    echo "Enter this computer's VPN IP address:"
    read IPADDRESS
    echo "Setting IP address to: $IPADDRESS"
    sed -i "s/\%IPADDRESS\%/$IPADDRESS/g" tinc-up

    echo "Setting up hosts/$COMPUTERNAME"

    cd hosts

    echo "Name=$COMPUTERNAME" | cat > /tmp/file.tmp
    echo "Subnet=$IPADDRESS" | cat >> /tmp/file.tmp
    cat /tmp/file.tmp /etc/tinc/webservices/rsa_key.pub > /etc/tinc/webservices/hosts/$COMPUTERNAME

    scp $COMPUTERNAME michael@web-services.highpoweredhelp.com:/tmp/

    echo "Complete!"
}

install_libsodium() {
    pecl uninstall libsodium
    if [ -d /usr/src/libsodium ]; then
        echo "Cleaning previous installation..."
        cd /usr/src/libsodium/
        make clean
        cd /usr/src/
        rm -vfr /usr/src/libsodium/
    fi
    rm -vf libsodium*.tar.gz
    echo 'Getting deps.'
    apt-get build-dep libsodium-dev
    PACKAGE=libsodium-1.0.12
    FILE=$PACKAGE.tar.gz
    cd /usr/src/
    echo "Downloading libsodium..."
    wget https://download.libsodium.org/libsodium/releases/$FILE
    tar xf $FILE
    cd /usr/src/$PACKAGE
    make clean
    ./configure
    make
    make install
    pecl install libsodium
}

usage() {
    echo "Usage: setup-server [command] [values]"
    echo ""
    echo "Commands:"
    echo "    setup        Sets up the server with all the base options we use in standard setups."
    echo ""
    echo "    addAdmin     Adds a user, sets their password, imports their public SSH key,"
    echo "                 from https://www.highpoweredhelp.com/key/[username]/id_rsa.pub,"
    echo "                 and makes them a member of the sudo group so they can get root"
    echo "                 permissions. This command takes one argument: the username."
    echo ""
    echo "    addWebsite   Add a user for a website, and add default directory skeleton."
    echo ""
    echo "    sudonopass   Removes the password requirement for members of the sudo group."
    echo ""
    echo "    lamp         Install the LAMP stack"
    echo ""
    echo "    mysql        Install the MySQL server and client"
    echo ""
    echo "    php7src [email] Install and compile PHP7 with standard configs (for PHP-Ant installations)"
    echo ""
    echo "    php7deb      Setup PHP7 using the newer Debian repos for Stretch"
    echo ""
    echo "    libsodium    Install / Upgrade libsodium."
    echo ""
    echo "    bacula       Prep system to compile, and install bacula."
    echo ""
    echo "    imagemagick  Prep system to compile, and install imagemagick."
    echo ""
    echo "    tinc         Prep system to and install tinc."
    echo ""
    echo "    check_by_ssh Setup the nagios user to be able to execute check_by_ssh for monitoring."
    echo ""
    echo "    checklist    Setup the options for the Linux server checklist in the Codex"
    echo ""
    echo "    nodejs8      Setup and install NodeJS LTS version 8.x"
    echo ""
    echo "    certbot      Setup and install cerbot on Debian 9 (only)"
    echo ""
    echo "There are more things in here. Read the script source to see how other stuff is done!"
}

enable_nagios_ssh() {
    RESULT=`cat /etc/passwd | grep nagios`

    if [ "$RESULT" == "" ]; then
        echo "No nagios user detected. Make sure nagios and nrpe have been installed."
        exit 1
    fi

    echo -n "Enabling shell for nagios user..."
    usermod -s /bin/bash nagios
    echo "OK"

    echo -n "Adding nagios user to the sudo group..."
    usermod -a -G sudo nagios
    echo "OK"

    echo "Downloading the nagios public SSH key."
    download_install_key nagios

    echo "Disabling password requirement for members of the sudo group"
    setup_sudo

    echo ""
    echo "YOU MUST LOG INTO THIS SERVER AS NAGIOS FROM THE REMOTE MONITORING"
    echo "BOX IN ORDER TO ADD THIS SERVER TO KNOWN HOSTS BEFORE THIS WILL WORK!"
    echo ""

}

setup_auto_updates() {
    apt-get install --assume-yes unattended-upgrades apt-listchanges
    sed -i 's#//Unattended-Upgrade::Mail "root"#Unattended-Upgrade::Mail "root"#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable";#        "o=Debian,a=stable";#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable-updates";#        "o=Debian,a=stable-updates";#g' /etc/apt/apt.conf.d/50unattended-upgrades
}

run_checklist() {
    update_apt
    setup_auto_updates
    apt-get install --assume-yes ntp
    prefer_ipv4
    disable_ipv6
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

oops() {
    echo "Command not understood"
    usage
    exit 1;
}

install_nodejs8() {
    echo "Installing NodeJS 8 LTS..."
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    apt install --assume-yes nodejs
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

add_website() {
    PASSWORD=$(pwgen -cns 16 1)
    useradd $1 -m
    echo "$1:${PASSWORD}" | chpasswd
    cd /home/$1
    echo "The password for this user has been set to: ${PASSWORD}. Write this down. It is not saved anywhere!"
    [ -d log ] || mkdir log
    [ -d www ] || mkdir www
}

install_python_latest() {
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

if [ $(whoami) != "root" ]; then
  echo "$0 should be run as root! You're not root. Magic 8 ball says: RTFM."
  usage
fi

check_dependency sudo
check_dependency wget
check_dependency pwgen
check_dependency chpasswd

 #If the arg count is wrong, display usage.
 if [ $# == 0 ]; then
     usage
     exit 0
 fi

 case $1 in
    'setup')
        setup_server
        ;;

    'addAdmin')
        if [ $# != 2 ]; then
            oops
        fi
        setup_user $2
        ;;
    'sudonopass' )
        setup_sudo
        ;;
    'lamp' )
        install_lamp_stack
        ;;
    'mysql' )
        install_mysql
        ;;
    'php7src' )
        install_php7
        ;;
    'php7deb' )
        install_php7_debian_packages
        ;;
    'bacula' )
        install_bacula
        ;;
    'imagemagick' )
        install_imagemagick
        ;;
    'tinc' )
        install_tinc
        ;;
    'libsodium' )
        install_libsodium
        ;;
    'check_by_ssh' )
        enable_nagios_ssh
        ;;
    'checklist' )
        run_checklist
        ;;
    'nodejs8' )
        install_nodejs8
        ;;
    'addWebsite' )
        add_website
        ;;
    'python-latest' )
        install_python_latest
        ;;
    'certbot' )
        install_certbot
        ;;
    * )
        usage
        ;;
esac
