# Gaming Mode as its own session, like SteamOS: gamescope is the compositor
# (DRM backend) on tty2 and drives the TV itself, instead of being a window
# nested in Hyprland (gaming-mode.nix). So VRR, HDR and the refresh rate are
# gamescope's own, nothing composites over it, and none of the nested mode's
# workarounds apply (window rule, unmap/VRR patches, cursor convar, quitting
# Fabric/Blueman, idle inhibitor).
#
# The desktop keeps running: Hyprland stays logged in on tty1 (greetd), only
# in the background (logind hands the screens and input to the active VT;
# every app keeps running). Back on the desktop, everything is as it was.
#
# Start: the "Gaming Mode (TV session)" launcher entry, i.e. `gaming-session`,
# which shuts the desktop Steam down, notes the TV's mode, starts
# gaming-session.service (switching to tty2) and waits for it to end, then
# brings the desktop Steam back. Leave: Steam's power menu "Switch to Desktop"
# (steamos-session-select, from gaming-mode.nix), or
# `systemctl stop gaming-session`; either way, back to tty1.
#
# Shared with gaming-mode.nix (imported by the gaming barrel): the patched
# gamescope, the steamos-* shims in Steam's FHS env, steam-http-loader and the
# mimeapps list, /etc/gaming-mode/{env,output}. steam-ui-watchdog runs here
# too (the CEF hang is Steam's, not the nesting's).
#
# Logs: journalctl -b -u gaming-session; the launcher's in
# $XDG_RUNTIME_DIR/gaming-mode/session-launcher.log.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  user = "muhammad";
  tty = "tty2";
  vt = "2";

  steam-ui-watchdog = pkgs.writeShellApplication {
    name = "steam-ui-watchdog";
    runtimeInputs = with pkgs; [coreutils procps curl jq websocat gawk gnugrep];
    text = builtins.readFile ./scripts/steam-ui-watchdog.sh;
  };

  # gamescope/steam come from the system (programs.* wrappers), via the
  # login shell's PATH.
  gaming-session-run = pkgs.writeShellApplication {
    name = "gaming-session-run";
    runtimeInputs = with pkgs; [coreutils procps mangohud gamemode steam-ui-watchdog];
    text = builtins.readFile ./scripts/gaming-session-run.sh;
  };

  # hyprctl/steam/gaming-mode come from the system.
  gaming-session = pkgs.writeShellApplication {
    name = "gaming-session";
    runtimeInputs = with pkgs; [coreutils procps util-linux jq config.systemd.package];
    text = builtins.readFile ./scripts/gaming-session.sh;
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "gaming-session";
    desktopName = "Gaming Mode (TV session)";
    comment = "Steam's gaming UI as its own session on the TV, like SteamOS; the desktop keeps running";
    icon = "steam";
    exec = "gaming-session";
    categories = ["Game"];
  };
in {
  environment.systemPackages = [gaming-session desktopItem];

  systemd.services.gaming-session = {
    description = "Gaming Mode: Steam in gamescope on ${tty}";
    after = ["systemd-user-sessions.service" "systemd-logind.service" "getty@${tty}.service"];
    wants = ["dbus.socket" "systemd-logind.service"];
    conflicts = ["getty@${tty}.service"];
    # Never restarted by a switch: that would kill a running game.
    restartIfChanged = false;
    unitConfig.ConditionPathExists = "/dev/${tty}";
    serviceConfig = {
      User = user;
      # A full login session on the VT (pam_systemd), as greetd gives Hyprland.
      PAMName = "gaming-session";
      TTYPath = "/dev/${tty}";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = tty;
      UtmpMode = "user";
      # Bring the VT to the front (logind then makes this session the active
      # one), and the desktop's back afterwards. `+`: as root.
      ExecStartPre = "+${pkgs.kbd}/bin/chvt ${vt}";
      ExecStopPost = "+${pkgs.kbd}/bin/chvt 1";
      # A login shell, for the system environment (PATH, environment.variables).
      ExecStart = "${pkgs.bashInteractive}/bin/bash -l -c 'exec ${lib.getExe gaming-session-run}'";
      # SIGTERM to the main process only: it shuts Steam down cleanly.
      KillMode = "mixed";
      TimeoutStopSec = 30;
    };
    environment = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_CLASS = "user";
      XDG_SESSION_DESKTOP = "gamescope";
      XDG_CURRENT_DESKTOP = "gamescope";
    };
  };

  # Switching to tty2 would otherwise spawn a text login there (logind's
  # autovt), which conflicts with the session.
  systemd.services."autovt@${tty}".enable = false;

  # As nixpkgs' cage module: no password (the unit is the gate), but a real
  # session (pam_systemd) with the PAM environment.
  security.pam.services.gaming-session = {
    useDefaultRules = false;
    rules = {
      auth = utils.pam.autoOrderRules [
        {
          name = "unix";
          control = "required";
          modulePath = config.security.pam.pam_unixModulePath;
          settings.nullok = true;
        }
      ];
      account = utils.pam.autoOrderRules [
        {
          name = "unix";
          control = "required";
          modulePath = config.security.pam.pam_unixModulePath;
        }
      ];
      session = utils.pam.autoOrderRules [
        {
          name = "unix";
          control = "required";
          modulePath = config.security.pam.pam_unixModulePath;
        }
        {
          name = "env";
          control = "required";
          modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
          settings.conffile = "/etc/pam/environment";
          settings.readenv = 0;
        }
        {
          name = "systemd";
          control = "required";
          modulePath = "${config.systemd.package}/lib/security/pam_systemd.so";
        }
      ];
    };
  };

  # The user may start and stop this one unit without a password, from a
  # local session (the desktop to start it, Steam inside it to stop it).
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "gaming-session.service" &&
          (action.lookup("verb") == "start" || action.lookup("verb") == "stop") &&
          subject.user == "${user}" && subject.local) {
        return polkit.Result.YES;
      }
    });
  '';
}
