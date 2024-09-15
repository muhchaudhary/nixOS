{
  inputs,
  config,
  pkgs,
  ...
}: {
  services.hypridle = let
    hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    loginctl = "${pkgs.systemd}/bin/loginctl";
  in {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on && ${loginctl} lock-session ";
        ignore_dbus_inhibit = true;
        lock_cmd = "pidof ${hyprlock} || ${hyprlock}";
      };
      listeners = [
        {
          timeout = 200;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 330;
          on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
