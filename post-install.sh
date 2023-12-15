#!/usr/bin/env bash

# RUN AFTER ARCH-CHROOT

# TODO:
#   - Set users and sudo config
#   - Install and setup grub grub-btrfs+daemon
#   - Set snapshots with snapper
#   - Install WM or DE + utilities

set_time() {
    ln -sf /usr/share/zoneinfo/America/Maceio /etc/localtime
    # hwclock --systohc # It may conflict dual booting with windows, check the arch wiki dualboot
    systemctl enable systemd-timesyncd.service
}

set_language() {
    # Editing /etc/locale.gen
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "LC_TIME=pt_BR.UTF-8" >> /etc/locale.conf
}

set_pacman() {
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

    pacman -S  --noconfirm --needed pacman-contrib reflector

    systemctl enable paccache.timer
    systemctl enable reflector.timer

    # Set reflector configs
    printf "--save /etc/pacman.d/mirrorlist\n" > /etc/xdg/reflector/reflector.conf
    printf "--protocol https\n" >> /etc/xdg/reflector/reflector.conf
    printf "--country Brazil,Argentina,Chile,Colombia,Ecuador,Paraguay\n" >> /etc/xdg/reflector/reflector.conf
    printf "--latest 5\n" >> /etc/xdg/reflector/reflector.conf
    printf "--sort age\n" >> /etc/xdg/reflector/reflector.conf
    echo "Pacman Configured"
}

set_bluetooth() {
    pacman -S  --noconfirm --needed bluez bluez-utils blueberry
    systemctl enable bluetooth.service
    echo "Bluetooth Enabled"
}

set_internet() {
    # Define hostname
    echo "ericpc" > /etc/hostname

    pacman -S --noconfirm --needed firewalld networkmanager

    # NetworkManager
    systemctl enable NetworkManager.service
    echo "NetworkManager Enabled"

    # Firewalld
    systemctl enable firewalld.service
    firewall-cmd --set-default-zone=home
    echo "Firewall enabled"
}

main() {
    set_time
    set_language
    set_pacman
    set_bluetooth
    set_internet
}
