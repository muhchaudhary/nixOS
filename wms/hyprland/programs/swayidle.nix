{
  config,
  pkgs,
  lib,
  ...
}: {
  # Do a systemctl --user restart swayidle.service. for some reason, it doesn't do that on each rebuild
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 60;
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
      {
        timeout = 90;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
    ];
  };
}
