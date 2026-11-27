# Gaming Mode, like SteamOS: Steam's gaming UI (`steam -gamepadui -steamos3`)
# as its own session, with gamescope as the compositor (DRM backend) of tty2,
# driving the TV itself. VRR, HDR and the refresh rate are gamescope's own,
# and nothing composites over it. `-e` (Steam integration): games always fill
# the screen, and the Quick Access Menu, FPS limiter, performance overlay and
# per-game resolution work like on the Deck.
#
# The desktop keeps running: Hyprland stays logged in on tty1 (greetd), only
# in the background (logind hands the screens and input to the active VT;
# every app keeps running). Back on the desktop, everything is as it was.
#
# Start: the "Gaming Mode" launcher entry, i.e. `gaming-session`, which shuts
# the desktop Steam down, notes the TV's mode, starts gaming-session.service
# (switching to tty2) and waits for it to end, then brings the desktop Steam
# back. Leave: Steam's power menu "Switch to Desktop" (steamos-session-select),
# or `systemctl stop gaming-session`; either way, back to tty1.
#
# Output: the one named in /etc/gaming-mode/output if the host pins one (the
# desktop: its TV, see its configuration.nix), else the focused monitor; at the
# mode Hyprland had it in.
#
# Host-specific environment: /etc/gaming-mode/env is sourced at start, if a
# host provides one (the desktop: steam-ui-fix.nix).
#
# steam-ui-watchdog kills a hung or bloated Big Picture (a Steam CEF bug after a
# quick game quit), so Steam reloads its UI instead of the screen freezing, and
# restarts it if it fell back to slow software rendering (CEF GPU process crash).
#
# Logs: journalctl -b -u gaming-session (the script's lines are tagged "bash");
# the launcher's in $XDG_RUNTIME_DIR/gaming-mode/session-launcher.log.
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
    runtimeEnv.GAMING_MODE_MIMEAPPS = gamescopeMimeapps;
    text = builtins.readFile ./scripts/gaming-session-run.sh;
  };

  # hyprctl/steam come from the system.
  gaming-session = pkgs.writeShellApplication {
    name = "gaming-session";
    runtimeInputs = with pkgs; [coreutils procps util-linux jq config.systemd.package];
    text = builtins.readFile ./scripts/gaming-session.sh;
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "gaming-session";
    desktopName = "Gaming Mode";
    comment = "Steam's gaming UI as its own session on the TV, like SteamOS; the desktop keeps running";
    icon = "steam";
    exec = "gaming-session";
    categories = ["Game"];
  };

  # With -steamos3, Steam's power menu "Switch to Desktop" runs this; on SteamOS
  # it switches sessions, here leaving Steam is enough: gaming-session-run sees
  # gamescope exit and ends the session. The marker tells it (and the watchdog)
  # that it's on purpose, not a crash to relaunch from.
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    touch "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gaming-mode/leaving" 2>/dev/null || true
    exec steam -shutdown
  '';

  # With -steamos3, Steam polls this for SteamOS's update branch (every few
  # seconds, "command not found" into its log); answers as SteamOS's stub does
  # (from CachyOS's gamescope-session): one branch, named after the OS.
  steamos-select-branch = pkgs.writeShellScriptBin "steamos-select-branch" ''
    case "''${1:-}" in
      -c | -l) . /etc/os-release && echo "$NAME" ;;
      stable) ;;
      *) echo "Usage: steamos-select-branch <stable|-c|-l>" >&2; exit 1 ;;
    esac
  '';

  # Inside Gaming Mode, links and documents opened by apps go to Steam's
  # overlay browser, as on SteamOS (steam_http_loader). gamescope sets
  # XDG_CURRENT_DESKTOP=gamescope, so gamescope-mimeapps.list applies only
  # there; gaming-session-run links it as ~/.config/gamescope-mimeapps.list,
  # since a system-wide one loses to the user's own mimeapps.list (spec lookup
  # order).
  steam-http-loader = pkgs.writeShellScriptBin "steam-http-loader" ''
    case "$1" in
      mailto:*) exec steam "steam://mailto/''${1#mailto:}" ;;
      *://*) exec steam "steam://openurl_external/$1" ;;
      *) exec steam "steam://openurl_external/file://$(realpath -- "$1")" ;;
    esac
  '';
  steamHttpLoaderItem = pkgs.makeDesktopItem {
    name = "steam_http_loader";
    desktopName = "Steam Link Handler";
    exec = "steam-http-loader %u";
    noDisplay = true;
    mimeTypes = ["x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/mailto" "text/html" "application/pdf"];
  };
  gamescopeMimeapps = pkgs.writeText "gamescope-mimeapps.list" ''
    [Default Applications]
    x-scheme-handler/http=steam_http_loader.desktop
    x-scheme-handler/https=steam_http_loader.desktop
    x-scheme-handler/mailto=steam_http_loader.desktop
    application/pdf=steam_http_loader.desktop
    application/x-extension-html=steam_http_loader.desktop
    text/html=steam_http_loader.desktop
  '';
in {
  # mangohud provides mangoapp, which `--mangoapp` starts: the overlay behind
  # the Quick Access Menu's Performance Overlay Level slider, as on SteamOS.
  environment.systemPackages = [gaming-session desktopItem pkgs.mangohud steamos-session-select steam-http-loader steamHttpLoaderItem];
  # Steam runs inside its FHS env, so it needs the shims on its own PATH too.
  # gamescope-wsi: the Vulkan layer (enabled by gamescope for its clients) that
  # lets games hand gamescope HDR swapchains. Patched to only offer the HDR
  # formats the driver can back: on NVIDIA it offered A2R10G10B10 + HDR10, then
  # refused to make the swapchain, so Longshot (HDR on) never started.
  programs.steam.extraPackages = [
    steamos-session-select
    steamos-select-branch
    (pkgs.gamescope-wsi.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./gamescope-wsi-supported-hdr-formats.patch];
    }))
  ];

  # gamescope-nvidia-gbm-scanout.patch: scanout buffers from GBM (enabled by
  # gaming-session-run, gamescope_drm_gbm_scanout=1), as Vulkan-allocated ones
  # show up corrupted at 4K on NVIDIA (gamescope#2309); see the patch header.
  # Cursor-sized buffers GBM refuses fall back to Vulkan (an error line each:
  # harmless). If a nixpkgs bump makes it fail to apply, refresh it against the
  # new source.
  programs.gamescope.package = pkgs.gamescope.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./gamescope-nvidia-gbm-scanout.patch];
  });

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
