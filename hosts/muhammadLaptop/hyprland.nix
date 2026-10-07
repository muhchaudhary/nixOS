# Laptop-specific hypridle timings + monitor layout. The base
# Hyprland home module already enables hypridle and sets settings.general; this
# only adds the listeners (module options merge).
{...}: {
  services.hypridle.settings.listener = [
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

  xdg.configFile."hypr/monitors.lua".source = ./hypr/monitors.lua;
}
