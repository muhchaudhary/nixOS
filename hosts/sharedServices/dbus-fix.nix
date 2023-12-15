{
  config,
  lib,
  pkgs,
  ...
}: {
  systemd.user.services.xdgFix = {
    script = ''
      dbus-update-activation-environment --systemd --all
    '';
    wantedBy = ["multi-user.target"];
  };
}
