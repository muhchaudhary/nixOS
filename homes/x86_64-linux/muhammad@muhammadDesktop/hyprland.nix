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
    hypridle = {
      enable = true;
      settings = {
        listener = [
          {
            timeout = 200;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 500;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 2500;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
