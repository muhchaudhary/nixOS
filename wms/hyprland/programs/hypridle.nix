{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hypridle.homeManagerModules.default
  ];

  services.hypridle = with pkgs; {
    enable = true;
    beforeSleepCmd = "${systemd}/bin/loginctl lock-session";
    lockCmd = lib.getExe config.programs.hyprlock.package;
    listeners = [
      {
        timeout = 200;
        onTimeout = lib.getExe config.programs.hyprlock.package;
      }
      {
        timeout = 330;
        onTimeout = "${systemd}/bin/systemctl suspend";
      }
    ];
  };
}
