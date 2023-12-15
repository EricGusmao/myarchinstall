#!/usr/bin/env bash

pacman -S  --noconfirm --needed bluez bluez-utils blueberry
systemctl enable bluetooth.service