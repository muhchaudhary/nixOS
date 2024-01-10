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
      # TODO: make ags window tell user that PC is about to sleep
      # {
      #   timeout = 50;
      #   command = "ags -b hypr -r sleep";
      # }
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
