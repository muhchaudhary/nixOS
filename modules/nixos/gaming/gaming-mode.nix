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
# quick game quit), so Steam reloads its UI instead of the screen freezing.
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

  gaming-mode = pkgs.writeShellApplication {
    name = "gaming-mode";
    # gamescope/steam/hyprctl come from the system (programs.* wrappers).
    runtimeInputs = with pkgs; [coreutils procps util-linux jq dbus config.systemd.package mangohud gamemode steam-ui-watchdog];
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
  environment.systemPackages = [gaming-mode steamos-session-select desktopItem pkgs.mangohud];
  # Steam runs inside its FHS env, so it needs the shim on its own PATH too.
  # gamescope-wsi: the Vulkan layer (enabled by gamescope for its clients) that
  # lets games hand gamescope HDR swapchains.
  programs.steam.extraPackages = [steamos-session-select pkgs.gamescope-wsi];

  # Nested gamescope hides (unmaps) its window whenever nothing inside is
  # focused, e.g. for a moment when a game exits, so the Hyprland window closed
  # and reopened each time (default size and open animation, then fullscreen).
  # Patched to keep the window up, holding the last frame until something is
  # focused again (cf. ValveSoftware/gamescope#1456). Caveat: a hung Steam UI
  # then shows as a frozen frame rather than a lost window, which the window
  # watchdog can't see; steam-ui-watchdog covers the known hang (an unresponsive
  # or bloated steamwebhelper), not a hang of the Steam client itself. If a
  # nixpkgs bump makes it fail to apply, refresh it against the new source.
  programs.gamescope.package = pkgs.gamescope.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./gamescope-nested-never-unmap.patch];
  });
}
