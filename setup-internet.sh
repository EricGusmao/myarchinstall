#!/usr/bin/env bash

pacman -S --noconfirm --needed firewalld networkmanager

#NetworkManager
systemctl enable NetworkManager.service

# Firewalld
systemctl enable firewalld.service
firewall-cmd --set-default-zone=home