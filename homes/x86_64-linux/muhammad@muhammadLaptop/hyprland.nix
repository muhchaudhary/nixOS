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
    hypridle = {
      enable = true;
      settings = {
        listener = [
          {
            timeout = 200;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 500;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };

  xdg.configFile."hypr/monitors.lua".source = ./hypr/monitors.lua;
}
