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
    pidof = "${pkgs.procps}/bin/pidof";
    notify-send = "${pkgs.libnotify}/bin/notify-send";
  in {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pidof} ${hyprlock} || ${hyprlock}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on && ${loginctl} lock-session ";
      };
      listener = [
        {
          timeout = 200;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 300;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 500;
          on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
