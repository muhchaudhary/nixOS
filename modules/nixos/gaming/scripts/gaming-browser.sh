# shellcheck shell=bash
# Shortcuts made when it also offered Zen may still pass the browser name first.
if [ "${1:-}" = chromium ]; then shift; fi

unset WAYLAND_DISPLAY NIXOS_OZONE_WL

# Gaming Mode passes its output size; measuring it here is too early (the
# game Xwayland starts at 1920x1080 and only then switches to the output's).
w=1920 h=1080
if [ -n "${GAMING_MODE_OUTPUT:-}" ]; then
  dims=$GAMING_MODE_OUTPUT
else
  dims=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ { print $2; exit }') || dims=""
fi
if [ -n "$dims" ]; then
  w=${dims%x*} h=${dims#*x}
fi
# Cursor size before Chromium's own scaling (so ~80 px at 4K, 40 at 1080p).
export XCURSOR_SIZE=32
s100=$(( h * 125 / 1080 ))
scale="$(( s100 / 100 )).$(printf %02d $(( s100 % 100 )))"

profile="${XDG_DATA_HOME:-$HOME/.local/share}/gaming-browser/chromium"
mkdir -p "$profile"

exec chromium \
  --ozone-platform=x11 \
  --disable-gpu-sandbox \
  --user-data-dir="$profile" \
  --force-device-scale-factor="$scale" \
  --window-position=0,0 \
  --window-size="$(( w * 100 / s100 )),$(( h * 100 / s100 ))" \
  --no-first-run --no-default-browser-check \
  "$@"
