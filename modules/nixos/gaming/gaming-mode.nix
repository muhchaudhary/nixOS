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
    text = builtins.readFile ./steam-ui-watchdog.sh;
  };

  gaming-mode = pkgs.writeShellApplication {
    name = "gaming-mode";
    # gamescope/steam/hyprctl come from the system (programs.* wrappers).
    runtimeInputs = with pkgs; [coreutils procps util-linux jq dbus config.systemd.package mangohud gamemode steam-ui-watchdog];
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
      # Leaving on purpose (`--exit`, Steam's "Switch to Desktop"): the
      # watchdog mustn't take Steam's window going away for a lost one.
      leaving="$state/leaving"
      # Relaunching after a lost window: still running, between gamescopes.
      restarting="$state/restarting"
      # The applet runs as the XDG-autostart unit (services.blueman); it also
      # spawns blueman-tray, which outlives it.
      blueman_unit=app-blueman@autostart.service
      hypr_scripts="$HOME/.config/hypr/scripts"

      running() { [ -f "$pidfile" ] && { kill -0 "$(cat "$pidfile")" 2>/dev/null || [ -f "$restarting" ]; }; }
      steam_running() { pgrep -u "$(id -u)" -x steam >/dev/null; }
      dispatch() { hyprctl eval "hl.dispatch($1)" >/dev/null; }
      set_auto_hdr() { hyprctl eval "hl.config({ render = { cm_auto_hdr = $1 } })" >/dev/null || true; }
      # The placement rule (see the header); `false` disables it again.
      set_window_rule() {
        hyprctl eval "hl.window_rule({ name = \"gaming-mode\", enabled = $1, match = { class = \"^gamescope\$\" }, workspace = \"name:gaming\", fullscreen = true })" >/dev/null || true
      }
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
          set_window_rule false
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

      # Whether gamescope (pid $1) has a Hyprland window: 0 yes, 1 no, 2 if
      # Hyprland can't be asked.
      has_window() {
        local clients
        clients=$(hyprctl clients -j) || return 2
        jq -e --argjson pid "$1" 'any(.[]; .pid == $pid)' <<<"$clients" >/dev/null || return 1
      }

      stop_gamescope() {
        shutdown_steam
        # gamescope exits once Steam (its child) has.
        for _ in $(seq 60); do kill -0 "$1" 2>/dev/null || break; sleep 0.5; done
        kill "$1" 2>/dev/null || true
      }

      exit_gaming_mode() {
        running || return 0
        touch "$leaving"
        stop_gamescope "$(cat "$pidfile")"
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

      rm -f "$leaving"

      # Host additions to Gaming Mode's environment (the desktop: Nvidia's
      # Steam overlay fix, see steam-ui-fix.nix).
      if [ -r /etc/gaming-mode/env ]; then
        # shellcheck disable=SC1091
        . /etc/gaming-mode/env
      fi

      # Output: a host can pin Gaming Mode to one monitor via
      # /etc/gaming-mode/output (the desktop: its TV), used if it's enabled;
      # else the focused monitor. Under Sunshine it's always the focused
      # (headless) output, at the Moonlight client's requested mode.
      output=""
      if [ -n "''${SUNSHINE_CLIENT_WIDTH:-}" ]; then
        w=$SUNSHINE_CLIENT_WIDTH h=$SUNSHINE_CLIENT_HEIGHT r=$SUNSHINE_CLIENT_FPS
      else
        if [ -r /etc/gaming-mode/output ]; then
          output=$(cat /etc/gaming-mode/output)
          hyprctl monitors -j | jq -e --arg o "$output" 'any(.[]; .name == $o)' >/dev/null || output=""
        fi
        read -r w h r < <(hyprctl monitors -j | jq -r --arg o "$output" \
          'first(.[] | select(if $o == "" then .focused else .name == $o end)) | "\(.width) \(.height) \(.refreshRate | round)"')
      fi
      echo "gaming mode: ''${output:-focused output} ''${w}x''${h}@''${r}"

      # An empty workspace right away, so the screen (and a stream) shows the
      # wallpaper rather than the desktop's windows while Steam starts; its
      # window only appears once it has drawn (seconds, or ~40 s on a first
      # run/update). Also before a relaunch, for the same reason.
      focus_gaming_workspace() {
        if [ -n "$output" ]; then dispatch "hl.dsp.focus({monitor=\"$output\"})"; fi
        dispatch 'hl.dsp.focus({workspace="name:gaming"})'
      }
      hyprctl activeworkspace -j | jq -r .name >"$prev_ws"
      focus_gaming_workspace

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

      launch_gamescope() {
        # steam-ui-watchdog probes Steam's CEF debug port, which Steam only
        # opens with this marker file present at its start (Decky needs it
        # too); ensured here so the watchdog never silently falls back to its
        # memory check alone.
        if [ -d "$HOME/.local/share/Steam" ]; then
          touch "$HOME/.local/share/Steam/.cef-enable-remote-debugging"
        fi
        set_window_rule true
        # setsid: Sunshine kills the app's process group when the stream is
        # quit; gamescope/Steam must survive that so `--exit` (its undo) can
        # shut Steam down cleanly instead.
        # gamescope_cursor_composite=2 (any gamescope_<convar> env var sets that
        # convar): gamescope draws the cursor itself. Nested, it otherwise only
        # hands it to Hyprland, which shows it only while Hyprland's own pointer
        # is over the window; Steam Input's mouse (a non-Steam app like
        # gaming-browser) moves gamescope's pointer, not Hyprland's, so no cursor.
        # GAMING_MODE_OUTPUT: the output size, for apps that size themselves
        # (gaming-browser); measured at their start, the game Xwayland can still
        # be at its initial 1920x1080.
        GAMING_MODE_OUTPUT="''${w}x''${h}" gamescope_cursor_composite=2 STEAM_MULTIPLE_XWAYLANDS=1 PROTON_ENABLE_HDR=1 DXVK_HDR=1 setsid gamescope \
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

        # GameMode (CPU governor/EPP to performance, etc.) for the same
        # lifetime: a stand-in process registered through gamemoderun, rather
        # than LD_PRELOADing it into Steam and everything Steam starts.
        gamemoderun tail --pid="$gamescope_pid" -f /dev/null &

        # Kills a hung or bloated Big Picture so Steam reloads its UI (a Steam
        # CEF bug after a quick game quit; see steam-ui-watchdog.sh).
        steam-ui-watchdog "$gamescope_pid" &
      }

      # Watchdog, every second while gamescope runs (placement is the window
      # rule's job): returns 1 when the window is lost. With --hdr-enabled,
      # gamescope unmaps its window when a game exits (HDR output off) and maps
      # it again ~0.2 s later (HDR back on). Sometimes HDR never comes back on,
      # and gamescope and Steam keep running with no window at all. Counting
      # starts once the window has first appeared (Steam's first start can
      # take ~40 s), and not while leaving on purpose (Steam's window goes
      # before gamescope exits).
      watch_gamescope() {
        local seen="" missing=0 rc
        while running; do
          if [ ! -f "$leaving" ]; then
            rc=0
            has_window "$gamescope_pid" 2>/dev/null || rc=$?
            if [ "$rc" = 0 ]; then
              seen=1 missing=0
            elif [ "$rc" = 1 ] && [ -n "$seen" ]; then
              missing=$((missing + 1))
              [ "$missing" -lt 10 ] || return 1
            fi
          fi
          sleep 1
        done
        return 0
      }

      # Stay in the foreground for gaming mode's lifetime (Sunshine ends the
      # stream when this exits, like leaving Gaming Mode on the Deck). A lost
      # window, or gamescope exiting without leaving on purpose (Steam or
      # gamescope crashed; `--exit` and "Switch to Desktop" set $leaving),
      # relaunches Gaming Mode (Steam restarts inside a new gamescope); if that
      # happens again within a minute, back to the desktop instead.
      last_restart=0
      launch_gamescope
      while :; do
        if watch_gamescope; then
          if [ -f "$leaving" ] || [ ! -f "$pidfile" ]; then break; fi
          reason="gamescope exited unexpectedly"
        else
          reason="gamescope's window has been gone for 10 s"
        fi
        now=$(date +%s)
        if [ $((now - last_restart)) -lt 60 ]; then
          echo "gaming mode: $reason, again within a minute: leaving Gaming Mode"
          touch "$leaving"
          stop_gamescope "$gamescope_pid"
          break
        fi
        last_restart=$now
        echo "gaming mode: $reason, relaunching"
        touch "$restarting"
        stop_gamescope "$gamescope_pid"
        wait_steam_gone 10
        rm -f "$restarting"
        # `--exit` while restarting: it removed the pidfile.
        [ -f "$pidfile" ] || break
        focus_gaming_workspace
        launch_gamescope
      done
      rm -f "$pidfile" "$leaving"
      wait_steam_gone 10
      restore_desktop
    '';
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
