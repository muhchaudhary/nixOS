# SteamOS-style Gaming Mode inside the Hyprland desktop: `gaming-mode` swaps the
# desktop Steam for Steam's gaming UI in a fullscreen nested gamescope
# (`-e`: Steam integration, so games always fill the screen, and the Quick
# Access Menu, FPS limiter, performance overlay and per-game resolution work
# like on the Deck).
#
# Start it from the "Gaming Mode" launcher entry. Back to Desktop Mode: Steam's
# power menu "Switch to Desktop", the launcher entry again (it toggles), or
# `gaming-mode --exit`. The desktop Steam (tray) and the Fabric shell are
# restarted if they were running.
#
# While it runs: Fabric (bar/OSD) is quit, since its layers draw over the game
# (Steam has its own volume OSD and Quick Access Menu), the Blueman applet is
# stopped (its "device connected" window pops up over the game when a
# controller connects and never closes), and an idle inhibitor is held, since
# hypridle can't see controller input and would lock the screen.
#
# HDR: gamescope runs with --hdr-enabled (Steam's Display settings then offer
# "Enable HDR"), and Hyprland's render:cm_auto_hdr is set to 1 for the session,
# so the monitor switches to HDR only while gamescope's fullscreen surface is
# HDR. It's 0 on the desktop, see hosts/muhammadDesktop/hypr/monitors.lua.
# Games reach gamescope's HDR through its WSI layer (gamescope-wsi, below);
# Proton/DXVK only offers HDR with PROTON_ENABLE_HDR/DXVK_HDR set. gamescope's
# window briefly disappears on every game exit (HDR off and on again) and
# occasionally never comes back; a watchdog relaunches Gaming Mode when it's
# been gone for 10 s, or when gamescope/Steam exit without leaving on purpose
# (a crash); twice within a minute: back to the desktop instead.
# steam-ui-watchdog kills a hung or bloated Big Picture (a Steam CEF bug after a
# quick game quit), so Steam reloads its UI instead of the screen freezing, and
# restarts it if it fell back to slow software rendering (CEF GPU process crash).
#
# Host-specific environment: /etc/gaming-mode/env is sourced at start, if a
# host provides one (the desktop: steam-ui-fix.nix).
#
# Output: the focused monitor, unless the host pins one by writing its name to
# /etc/gaming-mode/output (the desktop pins its TV, see its configuration.nix,
# and binds the "gaming" workspace to it in hypr/monitors.lua).
#
# Placement: while Gaming Mode runs, a Hyprland window rule ("gaming-mode",
# registered at each launch, disabled on exit) opens gamescope's window on the
# "gaming" workspace, fullscreen; also after an HDR toggle remaps it. The rule
# matches class "gamescope" (fixed, no per-instance app id), hence only while
# Gaming Mode runs: Heroic's gamescope games on the desktop stay untouched. A
# Hyprland config reload drops it until the next launch.
#
# Sunshine's "Gaming Mode" app runs it on the headless output at the client's
# resolution (SUNSHINE_CLIENT_* env); see hosts/muhammadDesktop/configuration.nix.
{
  config,
  pkgs,
  ...
}: let
  steam-ui-watchdog = pkgs.writeShellApplication {
    name = "steam-ui-watchdog";
    runtimeInputs = with pkgs; [coreutils procps curl jq websocat gawk gnugrep];
    text = builtins.readFile ./scripts/steam-ui-watchdog.sh;
  };

  # hyprctl comes from the system.
  gaming-mode-vrr = pkgs.writeShellApplication {
    name = "gaming-mode-vrr";
    runtimeInputs = with pkgs; [coreutils procps gnused xprop];
    text = builtins.readFile ./scripts/gaming-mode-vrr.sh;
  };

  gaming-mode = pkgs.writeShellApplication {
    name = "gaming-mode";
    # gamescope/steam/hyprctl come from the system (programs.* wrappers).
    runtimeInputs = with pkgs; [coreutils procps util-linux jq dbus config.systemd.package mangohud gamemode steam-ui-watchdog gaming-mode-vrr];
    runtimeEnv.GAMING_MODE_MIMEAPPS = gamescopeMimeapps;
    text = builtins.readFile ./scripts/gaming-mode.sh;
  };

  # With -steamos3, Steam's power menu "Switch to Desktop" runs this; on SteamOS it
  # switches sessions, here leaving Steam is enough: gaming-mode notices gamescope
  # exit and restores the desktop. The marker keeps its watchdog from taking the
  # closing window for a lost one (and relaunching).
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
  # there; gaming-mode links it as ~/.config/gamescope-mimeapps.list, since a
  # system-wide one loses to the user's own mimeapps.list (spec lookup order).
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

  desktopItem = pkgs.makeDesktopItem {
    name = "gaming-mode";
    desktopName = "Gaming Mode";
    comment = "Steam's gaming UI fullscreen in gamescope, like SteamOS (opening it again exits)";
    icon = "steam";
    exec = "gaming-mode --toggle";
    categories = ["Game"];
  };
in {
  # mangohud provides mangoapp, which `--mangoapp` starts: the overlay behind
  # the Quick Access Menu's Performance Overlay Level slider, as on SteamOS.
  environment.systemPackages = [gaming-mode steamos-session-select desktopItem pkgs.mangohud steam-http-loader steamHttpLoaderItem];
  # For gaming-session.nix, which links it the same way.
  environment.etc."gaming-mode/gamescope-mimeapps.list".source = gamescopeMimeapps;
  # Steam runs inside its FHS env, so it needs the shims on its own PATH too.
  # gamescope-wsi: the Vulkan layer (enabled by gamescope for its clients) that
  # lets games hand gamescope HDR swapchains.
  programs.steam.extraPackages = [steamos-session-select steamos-select-branch pkgs.gamescope-wsi];

  # Nested gamescope hides (unmaps) its window whenever nothing inside is
  # focused, e.g. for a moment when a game exits, so the Hyprland window closed
  # and reopened each time (default size and open animation, then fullscreen).
  # Patched to keep the window up, holding the last frame until something is
  # focused again (cf. ValveSoftware/gamescope#1456). Caveat: a hung Steam UI
  # then shows as a frozen frame rather than a lost window, which the window
  # watchdog can't see; steam-ui-watchdog covers the known hang (an unresponsive
  # or bloated steamwebhelper), not a hang of the Steam client itself. If a
  # nixpkgs bump makes it fail to apply, refresh it against the new source.
  #
  # gamescope-nested-vrr-capable.patch: nested, gamescope only reports the
  # display VRR-capable from presentation feedback with a variable (zero)
  # refresh, which Hyprland never sends (it reports the nominal rate), so Steam
  # never offered its VRR toggle. GAMESCOPE_NESTED_VRR_CAPABLE=1 (set by
  # gaming-mode only) reports it capable; gaming-mode-vrr.sh applies the toggle.
  #
  # gamescope-nvidia-gbm-scanout.patch: only for gaming-session.nix (gamescope on
  # the DRM backend), opt-in via gamescope_drm_gbm_scanout=1; see the patch header.
  programs.gamescope.package = pkgs.gamescope.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./gamescope-nested-never-unmap.patch
        ./gamescope-nested-vrr-capable.patch
        ./gamescope-nvidia-gbm-scanout.patch
      ];
  });
}
