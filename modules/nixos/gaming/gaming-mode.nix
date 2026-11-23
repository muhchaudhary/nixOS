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
# Proton/DXVK only offers HDR with PROTON_ENABLE_HDR/DXVK_HDR set.
#
# Sunshine's "Gaming Mode" app runs it on the headless output at the client's
# resolution (SUNSHINE_CLIENT_* env); see hosts/muhammadDesktop/configuration.nix.
{
  config,
  pkgs,
  ...
}: let
  gaming-mode = pkgs.writeShellApplication {
    name = "gaming-mode";
    # gamescope/steam/hyprctl come from the system (programs.* wrappers).
    runtimeInputs = with pkgs; [coreutils procps util-linux jq dbus config.systemd.package mangohud];
    text = ''
      state="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gaming-mode"
      mkdir -p "$state"
      pidfile="$state/gamescope.pid"
      # Set at start: Steam was running on the desktop (restart it afterwards)
      # and the workspace to return to.
      had_steam="$state/had-desktop-steam"
      prev_ws="$state/previous-workspace"
      had_fabric="$state/had-fabric"
      had_blueman="$state/had-blueman"
      prev_auto_hdr="$state/previous-cm-auto-hdr"
      # The applet runs as the XDG-autostart unit (services.blueman); it also
      # spawns blueman-tray, which outlives it.
      blueman_unit=app-blueman@autostart.service
      hypr_scripts="$HOME/.config/hypr/scripts"

      running() { [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; }
      steam_running() { pgrep -u "$(id -u)" -x steam >/dev/null; }
      dispatch() { hyprctl eval "hl.dispatch($1)" >/dev/null; }
      set_auto_hdr() { hyprctl eval "hl.config({ render = { cm_auto_hdr = $1 } })" >/dev/null || true; }
      # Anchored: a bare `run_fabric.py` would also match any shell or editor
      # whose command line merely mentions it.
      fabric_pattern='(^|/)python[0-9.]* run_fabric\.py( |$)'
      fabric_running() { pgrep -u "$(id -u)" -f "$fabric_pattern" >/dev/null; }

      # Wait (up to $1 s) for every Steam process to exit; kill stragglers.
      wait_steam_gone() {
        for _ in $(seq "$(( $1 * 2 ))"); do
          steam_running || return 0
          sleep 0.5
        done
        pkill -u "$(id -u)" -x steam || true
        sleep 1
      }

      # (`steam -shutdown` with no Steam running would start one first.)
      shutdown_steam() {
        if steam_running; then steam -shutdown >/dev/null 2>&1 || true; fi
      }

      # Back to Desktop Mode: previous workspace, and the desktop Steam (to the
      # tray, like at login) if it was running before. Both the gaming-mode
      # process and an `--exit` can get here, hence the lock and the
      # consume-once state files. `9>&-`: Steam must not inherit (and hold) it.
      restore_desktop() {
        (
          flock -w 10 9 || true
          if [ -f "$prev_ws" ]; then
            dispatch "hl.dsp.focus({workspace=\"$(cat "$prev_ws")\"})"
            rm -f "$prev_ws"
          fi
          if [ -f "$had_fabric" ]; then
            rm -f "$had_fabric"
            # Through Hyprland, so it gets the same environment as at login.
            fabric_running || dispatch "hl.dsp.exec_cmd(\"$hypr_scripts/launch_fabric\")"
          fi
          if [ -f "$prev_auto_hdr" ]; then
            set_auto_hdr "$(cat "$prev_auto_hdr")"
            rm -f "$prev_auto_hdr"
          fi
          if [ -f "$had_blueman" ]; then
            rm -f "$had_blueman"
            systemctl --user start "$blueman_unit" || true
          fi
          if [ -f "$had_steam" ]; then
            rm -f "$had_steam"
            # The gaming-mode Steam may still be exiting: let it finish first,
            # or the relaunch would just hand off to (and die with) it.
            wait_steam_gone 15
            setsid -f steam -silent >/dev/null 2>&1 9>&-
          fi
        ) 9>"$state/lock"
      }

      exit_gaming_mode() {
        running || return 0
        local pid
        pid=$(cat "$pidfile")
        shutdown_steam
        # gamescope exits once Steam (its child) has.
        for _ in $(seq 60); do kill -0 "$pid" 2>/dev/null || break; sleep 0.5; done
        kill "$pid" 2>/dev/null || true
        rm -f "$pidfile"
        wait_steam_gone 10
        restore_desktop
      }

      case "''${1:-}" in
        --exit) exit_gaming_mode >>"$state/log" 2>&1; exit 0 ;;
        --toggle) if running; then exit_gaming_mode >>"$state/log" 2>&1; exit 0; fi ;;
        "") ;;
        *) echo "usage: gaming-mode [--toggle|--exit]" >&2; exit 2 ;;
      esac

      if running; then
        echo "gaming mode is already running" >&2
        exit 0
      fi

      # gamescope/Steam output, for debugging (Sunshine discards it).
      exec >"$state/log" 2>&1

      # Size: the Moonlight client's request when started by Sunshine, else the
      # focused monitor's current mode.
      if [ -n "''${SUNSHINE_CLIENT_WIDTH:-}" ]; then
        w=$SUNSHINE_CLIENT_WIDTH h=$SUNSHINE_CLIENT_HEIGHT r=$SUNSHINE_CLIENT_FPS
      else
        read -r w h r < <(hyprctl monitors -j | jq -r 'first(.[] | select(.focused)) | "\(.width) \(.height) \(.refreshRate | round)"')
      fi
      echo "gaming mode: ''${w}x''${h}@''${r}"

      # An empty workspace right away, so the screen (and a stream) shows the
      # wallpaper rather than the desktop's windows while Steam starts; its
      # window only appears once it has drawn (seconds, or ~40 s on a first
      # run/update).
      hyprctl activeworkspace -j | jq -r .name >"$prev_ws"
      dispatch 'hl.dsp.focus({workspace="name:gaming"})'

      rm -f "$had_fabric"
      if fabric_running; then
        touch "$had_fabric"
        "$hypr_scripts/fabric_send" quit || true
        sleep 1
        pkill -u "$(id -u)" -f "$fabric_pattern" || true
      fi

      # Back to the desktop's value on exit (see restore_desktop).
      if [ ! -f "$prev_auto_hdr" ]; then
        hyprctl getoption render:cm_auto_hdr -j | jq -r .int >"$prev_auto_hdr" || rm -f "$prev_auto_hdr"
      fi
      set_auto_hdr 1

      rm -f "$had_blueman"
      if systemctl --user --quiet is-active "$blueman_unit"; then
        touch "$had_blueman"
        systemctl --user stop "$blueman_unit" || true
      fi
      pkill -u "$(id -u)" -f '(^|/)\.?blueman-(applet|tray)' || true

      # One Steam instance per user: the desktop one has to go first.
      rm -f "$had_steam"
      if steam_running; then
        touch "$had_steam"
        shutdown_steam
        wait_steam_gone 30
      fi

      # setsid: Sunshine kills the app's process group when the stream is quit;
      # gamescope/Steam must survive that so `--exit` (its undo) can shut
      # Steam down cleanly instead.
      STEAM_MULTIPLE_XWAYLANDS=1 PROTON_ENABLE_HDR=1 DXVK_HDR=1 setsid gamescope \
        -W "$w" -H "$h" -w "$w" -h "$h" -r "$r" \
        -f -e --xwayland-count 2 --mangoapp --hdr-enabled \
        -- steam -gamepadui -steamos3 &
      gamescope_pid=$!
      echo "$gamescope_pid" >"$pidfile"

      # hypridle only sees keyboard/mouse; hold an idle inhibitor (which it
      # honours) until gamescope exits, so a controller-only session doesn't
      # lock or blank the screen. Sleep from Steam's power menu still works.
      systemd-inhibit --what=idle --who=gaming-mode --why="Gaming Mode" \
        tail --pid="$gamescope_pid" -f /dev/null &

      # Make sure the window ends up fullscreen once it appears (`-f` is only a
      # request, and it can map before that lands).
      (
        for _ in $(seq 240); do
          running || break
          addr=$(hyprctl clients -j | jq -r --argjson pid "$gamescope_pid" \
            'first(.[] | select(.pid == $pid)) | .address' 2>/dev/null) || true
          if [ -n "$addr" ] && [ "$addr" != null ]; then
            sleep 1
            dispatch "hl.dsp.window.fullscreen({action='set', window='address:$addr'})"
            break
          fi
          sleep 0.5
        done
      ) &

      # Stay in the foreground for gaming mode's lifetime (Sunshine ends the
      # stream when this exits, like leaving Gaming Mode on the Deck).
      while running; do sleep 1; done
      rm -f "$pidfile"
      wait_steam_gone 10
      restore_desktop
    '';
  };

  # With -steamos3, Steam's power menu "Switch to Desktop" runs this; on SteamOS it
  # switches sessions, here leaving Steam is enough: gaming-mode notices gamescope
  # exit and restores the desktop.
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
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
}
