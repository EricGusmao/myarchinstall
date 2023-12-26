#!/usr/bin/env bash

# RUN WHEN YOU'RE ON CHROOT

# TODO:
#   - Set users and sudo config
#   - Install and setup grub grub-btrfs+daemon
#   - Set snapshots with snapper
#   - Install WM or DE + utilities

set_time() {
    ln -sf /usr/share/zoneinfo/America/Maceio /etc/localtime
    # hwclock --systohc !!! IT MAY CONFLICT DUAL BOOTING WITH WINDOWS, CHECK THE ARCH WIKI DUALBOOT !!!
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

install_grub() {
    pacman -S --noconfirm --needed grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
    # Set linux as the main kernel, so it won't boot using the lts kernel by default
    sed -i -e '3iGRUB_TOP_LEVEL="/boot/vmlinuz-linux"\' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

set_snapshots(){
    #TODO
}

set_apparmor() {
    pacman -S --noconfirm --needed apparmor
    systemctl enable apparmor.service
    # Load apparmor in the kernel
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/^\(.*\)\("\)/\1 apparmor=1 security=apparmor\2/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

main() {
    set_time
    set_language
    set_pacman
    set_bluetooth
    set_internet
    install_grub
    set_snapshots
    set_apparmor
}
main
