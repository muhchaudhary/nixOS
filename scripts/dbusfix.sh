#!/bin/sh
dbus-update-activation-environment --systemd --all
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service