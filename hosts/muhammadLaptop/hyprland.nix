# Laptop-specific hypridle timings + monitor layout + lid handling. The base
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

  home.file.".config/hypr/scripts/lid_close" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      count=$(hyprctl monitors | grep -c "^Monitor")
      if [ "$count" -gt 1 ]; then
          hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
      else
          systemctl suspend
      fi
    '';
  };
}
