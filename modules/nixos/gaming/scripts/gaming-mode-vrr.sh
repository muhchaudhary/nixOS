# shellcheck shell=bash
# gaming-mode-vrr GAMESCOPE_PID: makes Steam's "Enable VRR" toggle (Quick Access
# Menu > Performance) switch Hyprland's VRR, for as long as Gaming Mode's
# gamescope runs (started by gaming-mode, see gaming-mode.nix).
#
# Nested, gamescope can't change the host's VRR: Steam's toggle only sets
# GAMESCOPE_VRR_ENABLED on gamescope's root Xwayland, which nothing acted on.
# This follows that property and sets Hyprland's misc:vrr to match. Steam
# only offers the toggle while gamescope reports the display VRR-capable,
# which nested it never does under Hyprland; gaming-mode sets
# GAMESCOPE_NESTED_VRR_CAPABLE=1 (gamescope-nested-vrr-capable.patch) for that,
# and puts the desktop's own VRR setting back on exit.
#
# Why switch it off at all: VRR follows the frame rate, and Steam's menus or
# the Gaming Browser deliver frames unevenly (nothing on a still page, bursts
# at 144 fps on any change), so the TV hops between ~48 and 144 Hz several
# times a second, visible on many TVs as a brightness shimmer.

gamescope_pid=$1

# gamescope's root Xwayland: the DISPLAY it gave its child (gamescopereaper,
# which runs Steam). Wait for it while gamescope starts.
display=""
for _ in $(seq 60); do
  kill -0 "$gamescope_pid" 2>/dev/null || exit 0
  for child in $(pgrep -P "$gamescope_pid"); do
    display=$(tr '\0' '\n' <"/proc/$child/environ" 2>/dev/null | sed -n 's/^DISPLAY=//p') || display=""
    [ -n "$display" ] && break 2
  done
  sleep 1
done
[ -n "$display" ] || { echo "gaming-mode-vrr: no gamescope DISPLAY found"; exit 0; }

set_vrr() {
  hyprctl eval "hl.config({ misc = { vrr = $1 } })" >/dev/null || true
}

# Steam writes the property when it starts (its saved setting; gamescope's
# own default, off, comes first) and on every toggle; xprop exits once
# gamescope's Xwayland is gone.
current=""
xprop -display "$display" -root -spy GAMESCOPE_VRR_ENABLED 2>/dev/null |
  while read -r line; do
    case "$line" in
      "GAMESCOPE_VRR_ENABLED(CARDINAL) = "[01]) want=${line##* } ;;
      *) continue ;;
    esac
    [ "$want" = "$current" ] && continue
    current=$want
    echo "gaming-mode-vrr: Steam's VRR toggle $([ "$want" = 1 ] && echo on || echo off), setting Hyprland's VRR to $want"
    set_vrr "$want"
  done
