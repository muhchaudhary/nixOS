# No login screen: greetd logs muhammad straight into Hyprland (UWSM) at boot,
# and hyprlock locks the session as soon as it's up, so the lock screen is the
# login screen. Logging out lands on tuigreet (text greeter on tty1) instead
# of logging straight back in.
#
# hyprlock uses ext-session-lock: if it crashes, Hyprland keeps the screen
# locked rather than showing the desktop. With no password at login,
# gnome-keyring is unlocked by hyprlock's PAM stack on the first unlock instead.
{
  config,
  lib,
  pkgs,
  ...
}: let
  hyprland = "${lib.getExe config.programs.uwsm.package} start -- hyprland-uwsm.desktop";
in {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      initial_session = {
        command = hyprland;
        user = "muhammad";
      };
      default_session.command = "${lib.getExe pkgs.tuigreet} --time --remember --asterisks --cmd '${hyprland}'";
    };
  };

  # Lock the auto-logged-in session right away (UWSM starts
  # graphical-session.target once Hyprland is up).
  systemd.user.services.hyprlock-on-login = {
    description = "Lock the session at login (no display-manager password)";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe config.programs.hyprlock.package;
    };
  };

  security.pam.services.hyprlock.enableGnomeKeyring = true;
}
