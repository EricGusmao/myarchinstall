#!/usr/bin/env bash

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
