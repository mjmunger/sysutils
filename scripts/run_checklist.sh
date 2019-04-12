#!/usr/bin/env bash


run_checklist() {
    update_apt
    setup_auto_updates
    apt-get install --assume-yes ntp vim
    prefer_ipv4
    disable_ipv6
}

setup_auto_updates() {
    apt-get install --assume-yes unattended-upgrades apt-listchanges
    sed -i 's#//Unattended-Upgrade::Mail "root"#Unattended-Upgrade::Mail "root"#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable";#        "o=Debian,a=stable";#g' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i 's#// *"o=Debian,a=stable-updates";#        "o=Debian,a=stable-updates";#g' /etc/apt/apt.conf.d/50unattended-upgrades
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