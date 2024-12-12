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
        "HDMI-A-1, 2560x1440@75, 0x0, 1"
        "DP-1,1920x1080@60,2560x0,1"
      ];
      misc.vrr = 1;
    };
  };
}
