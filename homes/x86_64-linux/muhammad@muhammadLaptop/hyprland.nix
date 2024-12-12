{
  lib,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
with lib;
with lib.internal; {
  internal.desktop.hyprland = {
    enable = true;
    type = "desktop";
    settings = {
      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
      ];
    };
  };
}
