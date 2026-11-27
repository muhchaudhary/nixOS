# shellcheck shell=bash
# gaming-session-run: the main process of gaming-session.service (see
# gaming-session.nix): Steam's gaming UI in gamescope as the compositor of
# tty2, driving the TV itself. Exits (ending the session, back to the
# desktop's VT) once Steam leaves on purpose ("Switch to Desktop", or the
# unit stopped); a crash relaunches it, twice within a minute exits.
state="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gaming-mode"
mkdir -p "$state"
# Set by steamos-session-select ("Switch to Desktop") and by a stop below;
# steam-ui-watchdog stands down while it exists.
leaving="$state/leaving"
rm -f "$leaving"

# A login shell (see the unit) gives the system environment; the user bus is
# the desktop session's, shared (one per user).
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
# gamescope is the compositor here: it mustn't find a display to nest in.
unset WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE

# Host additions (the desktop: Nvidia's Steam overlay fix, steam-ui-fix.nix).
if [ -r /etc/gaming-mode/env ]; then
  # shellcheck disable=SC1091
  . /etc/gaming-mode/env
fi

# Steam feature switches, from SteamOS's own session script (as forked by
# CachyOS, github.com/CachyOS/gamescope-session); only those that apply on
# this hardware. Everything below inherits them via gamescope.
# - Upscaling filters (FSR/NIS/pixel) in the Quick Access Menu.
export STEAM_GAMESCOPE_NIS_SUPPORTED=1 STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT=1
# - HDR and VRR controls.
export STEAM_GAMESCOPE_HDR_SUPPORTED=1 STEAM_GAMESCOPE_VRR_SUPPORTED=1
# - SDL games keep running when the overlay or Quick Access Menu takes focus.
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
# - Links open in Steam's overlay browser, not the desktop's browser: from
#   Steam Runtime apps via SRT, from the rest via gamescope-mimeapps.list
#   (gamescope sets XDG_CURRENT_DESKTOP=gamescope; in ~/.config, where it
#   outranks the user's mimeapps.list) and steam-http-loader.
#   NIXOS_XDG_OPEN_USE_PORTAL would send xdg-open through the desktop portal,
#   which runs in the Hyprland session and opens its default browser instead.
export SRT_URLOPEN_PREFER_STEAM=1
unset NIXOS_XDG_OPEN_USE_PORTAL
ln -sfn "$GAMING_MODE_MIMEAPPS" "${XDG_CONFIG_HOME:-$HOME/.config}/gamescope-mimeapps.list"
# - Steam's on-screen keyboard as the input method of Qt/GTK apps.
export QT_IM_MODULE=steam GTK_IM_MODULE=Steam
# - Performance overlay presets as on SteamOS (incl. the horizontal bar).
#   Steam writes mangoapp's config to this file; hidden until it does.
export STEAM_USE_MANGOAPP=1 STEAM_MANGOAPP_PRESETS_SUPPORTED=1 STEAM_MANGOAPP_HORIZONTAL_SUPPORTED=1
export MANGOHUD_CONFIGFILE="$state/mangohud.config"
echo no_display >"$MANGOHUD_CONFIGFILE"
# - One Xwayland for Steam, another for games (--xwayland-count 2); HDR in
#   Proton/DXVK games (they only offer it with these set).
export STEAM_MULTIPLE_XWAYLANDS=1 PROTON_ENABLE_HDR=1 DXVK_HDR=1
# Scanout buffers from GBM instead of Vulkan: on NVIDIA, Vulkan-allocated ones
# show up corrupted at 4K (gamescope#2309; gamescope-nvidia-gbm-scanout.patch).
export gamescope_drm_gbm_scanout=1

# Output and mode, as the desktop had them (written by the gaming-session
# launcher). Without it gamescope picks a connected output's preferred mode.
mode_args=()
if read -r name w h r <"$state/session-output" 2>/dev/null; then
  mode_args=(--prefer-output "$name" -W "$w" -H "$h" -r "$r")
  # For apps that size themselves (gaming-browser).
  export GAMING_MODE_OUTPUT="${w}x${h}"
fi
# --hide-cursor-delay: the cursor hides after 3 s idle, as on SteamOS.
gamescope_args=(-e --xwayland-count 2 --mangoapp --hdr-enabled --hide-cursor-delay 3000)

# Trial knob (no rebuild between tests): may replace gamescope_args, or unset
# variables from /etc/gaming-mode/env (e.g. STEAM_EXTRA_LD_PRELOAD).
overrides="${XDG_CONFIG_HOME:-$HOME/.config}/gaming-session/overrides.sh"
if [ -r "$overrides" ]; then
  echo "gaming-session: sourcing $overrides"
  # shellcheck disable=SC1090
  . "$overrides"
fi
echo "gaming-session: ${mode_args[*]:-preferred output and mode} ${gamescope_args[*]}"

gamescope_pid=""
# Stopping the unit (KillMode=mixed: SIGTERM to this process only): let Steam
# shut down cleanly, gamescope follows it.
stop() {
  touch "$leaving"
  steam -shutdown >/dev/null 2>&1 || true
  if [ -n "$gamescope_pid" ]; then
    for _ in $(seq 40); do kill -0 "$gamescope_pid" 2>/dev/null || break; sleep 0.5; done
    kill "$gamescope_pid" 2>/dev/null || true
  fi
  exit 0
}
trap stop TERM INT

launch() {
  # steam-ui-watchdog's probes and Decky need Steam's CEF debug port.
  if [ -d "$HOME/.local/share/Steam" ]; then
    touch "$HOME/.local/share/Steam/.cef-enable-remote-debugging"
  fi
  gamescope --backend drm "${mode_args[@]}" "${gamescope_args[@]}" \
    -- steam -gamepadui -steamos3 &
  gamescope_pid=$!
  gamemoderun tail --pid="$gamescope_pid" -f /dev/null &
  steam-ui-watchdog "$gamescope_pid" &
  reap_gamescope "$gamescope_pid" &
}

# Leaving on purpose, gamescope can hang on its way out (seen: ~25 s in
# libseat's logind ReleaseDevice, then a segfault), holding the VT on a
# frozen screen. Once Steam is gone, give it 3 s, then kill it: logind takes
# the devices back either way, and the unit's chvt returns to the desktop.
reap_gamescope() {
  while kill -0 "$1" 2>/dev/null; do
    if [ -f "$leaving" ] && ! pgrep -u "$(id -u)" -x steam >/dev/null; then
      sleep 3
      kill -0 "$1" 2>/dev/null || return 0
      echo "gaming-session: gamescope still up 3 s after Steam left, killing it"
      kill -9 "$1" 2>/dev/null || true
      return 0
    fi
    sleep 1
  done
}

last_restart=0
while :; do
  launch
  # `wait` returns early on a trapped signal; stop() then takes over.
  wait "$gamescope_pid" || true
  [ -f "$leaving" ] && break
  now=$(date +%s)
  if [ $((now - last_restart)) -lt 60 ]; then
    echo "gaming-session: gamescope exited unexpectedly again within a minute, leaving"
    break
  fi
  last_restart=$now
  echo "gaming-session: gamescope exited unexpectedly, relaunching"
  sleep 2
done
rm -f "$leaving"
