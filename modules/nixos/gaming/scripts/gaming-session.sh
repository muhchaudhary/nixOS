# shellcheck shell=bash
# gaming-session: Gaming Mode as its own session (see gaming-session.nix). Run
# from the Hyprland desktop: hands the TV to gaming-session.service on tty2 and
# waits for it to end, then puts the desktop Steam back.
state="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gaming-mode"
mkdir -p "$state"
unit=gaming-session.service
exec >>"$state/session-launcher.log" 2>&1

if systemctl --quiet is-active "$unit"; then
  echo "gaming-session: already running"
  exit 0
fi

steam_running() { pgrep -u "$(id -u)" -x steam >/dev/null; }
# Wait (up to $1 s) for every Steam process to exit; kill stragglers.
wait_steam_gone() {
  for _ in $(seq "$(($1 * 2))"); do
    steam_running || return 0
    sleep 0.5
  done
  pkill -u "$(id -u)" -x steam || true
  sleep 1
}

had_steam=""

# The mode gamescope should set: the desktop's for the pinned output (the TV,
# /etc/gaming-mode/output), else the focused monitor's. Asked now, while
# Hyprland drives the screens; the session reads it.
output=$(cat /etc/gaming-mode/output 2>/dev/null || true)
hyprctl monitors -j | jq -r --arg o "$output" \
  'first((.[] | select(.name == $o)), (.[] | select(.focused)))
   | "\(.name) \(.width) \(.height) \(.refreshRate | round)"' >"$state/session-output" ||
  rm -f "$state/session-output"

# One Steam per user: the desktop one goes first, and comes back afterwards.
if steam_running; then
  had_steam=1
  steam -shutdown >/dev/null 2>&1 || true
  wait_steam_gone 30
fi

# Lock the desktop: it stays logged in on tty1 behind the session, and with
# the session's idle inhibitor hypridle won't lock it. Through logind, so
# hypridle runs its lock_cmd (hyprlock), as for any other lock.
desktop_session=$(loginctl show-user "$(id -u)" -p Display --value 2>/dev/null || true)
if [ -n "$desktop_session" ]; then
  loginctl lock-session "$desktop_session" || echo "gaming-session: couldn't lock the desktop"
fi

echo "gaming-session: starting ($(cat "$state/session-output" 2>/dev/null || echo "no output info"))"
# --wait: returns once the session has ended (Steam's "Switch to Desktop").
systemctl start --wait "$unit" || echo "gaming-session: $unit failed, see journalctl -b -u $unit"
echo "gaming-session: back on the desktop"

if [ -n "$had_steam" ]; then
  wait_steam_gone 15
  setsid -f steam -silent >/dev/null 2>&1
fi
