# Desktop-specific hypridle timings, monitor layout and per-monitor lock screen. The base Hyprland home
# module (modules/home/hyprland) already enables hypridle and
# sets settings.general; this only adds the listeners (module options merge).
{hyprlockWidgets, ...}: let
  # Lock screen per monitor: the LG as usual, the TV (couch distance, and
  # likely typed on from a controller) the same layout at twice the size.
  dp = hyprlockWidgets {monitor = "DP-1";};
  tv = hyprlockWidgets {
    monitor = "HDMI-A-1";
    scale = 2;
  };
in {
  programs.hyprlock.settings = {
    label = dp.label ++ tv.label;
    input-field = dp.input-field ++ tv.input-field;
  };

  services.hypridle.settings.listener = [
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

  xdg.configFile."hypr/monitors.lua".source = ./hypr/monitors.lua;
}
