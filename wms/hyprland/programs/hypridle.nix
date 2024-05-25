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
      lockCmd = "pidof hyprlock || ${hyprlock}";
      beforeSleepCmd = "${hyprctl} dispatch dpms off";
      afterSleepCmd = "${hyprctl} dispatch dpms on && ${loginctl} lock-session ";
      listeners = [
        {
          timeout = 200;
          onTimeout = "${loginctl} lock-session";
        }
        {
          timeout = 330;
          onTimeout = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
