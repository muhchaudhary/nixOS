# A web browser for Gaming Mode (gaming-mode.nix): `gaming-browser [chromium|zen] [args/URLs…]`
# (default chromium), added to Steam once as a non-Steam game ("Add a Non-Steam
# Game" → "Gaming Browser"; it syncs into Gaming Mode), with Steam Input's "Web
# Browser" controller template. Zen: add "Gaming Browser (Zen)" the same way.
# Extra arguments go to the browser, e.g. a shortcut running
# `gaming-browser chromium --kiosk https://example.org` for a single-site "app".
#
# - --disable-gpu-sandbox: Steam preloads its overlay (gameoverlayrenderer.so)
#   into everything it launches; its glXSwapBuffers hook makes a syscall the
#   GPU process's seccomp sandbox forbids, so every frame crashed it (black
#   screen for ~1 min until Chromium fell back to software). SteamOS's Flatpak
#   Chrome never gets the overlay injected; here it loads and works instead.
#   The renderer sandboxes (the ones that face web content) stay on.
# - X11 only: Gaming Mode's Steam (and so this) inherits Hyprland's
#   WAYLAND_DISPLAY/NIXOS_OZONE_WL/MOZ_ENABLE_WAYLAND, which would open the
#   window on the desktop instead of inside gamescope.
# - Own profile per browser (~/.local/share/gaming-browser): with the desktop's
#   profile, an already running desktop browser would get the request and open
#   the window on the desktop; it also keeps the TV session apart.
# - Window sized to gamescope's screen (no window manager there to maximize
#   it; size from gaming-mode's GAMING_MODE_OUTPUT), and scaled for the couch:
#   1.25× at 1080p, 2.5× at 4K (both browsers' window sizes are in scaled
#   pixels, so they're divided by the scale). Bigger cursor (XCURSOR_SIZE,
#   times that scale): nested gamescope doesn't scale cursors itself.
{
  pkgs,
  inputs,
  ...
}: let
  zen = inputs.zen-browser.result.packages.${pkgs.stdenv.hostPlatform.system}.default;

  gaming-browser = pkgs.writeShellApplication {
    name = "gaming-browser";
    runtimeInputs = [pkgs.coreutils pkgs.gawk pkgs.xdpyinfo];
    text = ''
      browser=chromium
      case "''${1:-}" in
        chromium | zen) browser=$1; shift ;;
      esac

      unset WAYLAND_DISPLAY NIXOS_OZONE_WL
      export MOZ_ENABLE_WAYLAND=0 GDK_BACKEND=x11

      # Gaming Mode passes its output size; measuring it here is too early (the
      # game Xwayland starts at 1920x1080 and only then switches to the output's).
      w=1920 h=1080
      if [ -n "''${GAMING_MODE_OUTPUT:-}" ]; then
        dims=$GAMING_MODE_OUTPUT
      else
        dims=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ { print $2; exit }') || dims=""
      fi
      if [ -n "$dims" ]; then
        w=''${dims%x*} h=''${dims#*x}
      fi
      # Cursor size before Chromium's own scaling (so ~80 px at 4K, 40 at 1080p).
      export XCURSOR_SIZE=32
      s100=$(( h * 125 / 1080 ))
      scale="$(( s100 / 100 )).$(printf %02d $(( s100 % 100 )))"

      profiles="''${XDG_DATA_HOME:-$HOME/.local/share}/gaming-browser"
      mkdir -p "$profiles"

      case "$browser" in
        chromium)
          exec ${pkgs.chromium}/bin/chromium \
            --ozone-platform=x11 \
            --disable-gpu-sandbox \
            --user-data-dir="$profiles/chromium" \
            --force-device-scale-factor="$scale" \
            --window-position=0,0 \
            --window-size="$(( w * 100 / s100 )),$(( h * 100 / s100 ))" \
            --no-first-run --no-default-browser-check \
            "$@"
          ;;
        zen)
          profile="$profiles/zen"
          mkdir -p "$profile"
          # Rewritten every start, so the scale follows the screen.
          printf 'user_pref("layout.css.devPixelsPerPx", "%s");\n' "$scale" >"$profile/user.js"
          # Steam's preloaded overlay links libGL.so.1, which the loader in Zen's
          # own wrapper (another nixpkgs) can't find in Steam's environment:
          # "bash: error while loading shared libraries: libGL.so.1".
          export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}${pkgs.libglvnd}/lib"
          exec ${zen}/bin/zen-beta \
            --no-remote --profile "$profile" \
            --width "$(( w * 100 / s100 ))" --height "$(( h * 100 / s100 ))" \
            "$@"
          ;;
      esac
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "gaming-browser";
    desktopName = "Gaming Browser";
    comment = "Web browser for Gaming Mode (add to Steam as a non-Steam game)";
    icon = "web-browser";
    exec = "gaming-browser %U";
    categories = ["Network" "WebBrowser"];
  };

  # Its own shortcut: Gaming Mode's Steam puts launch options in front of the
  # command (`zen <launch wrapper> gaming-browser`), so `zen` can't be passed there.
  zenDesktopItem = pkgs.makeDesktopItem {
    name = "gaming-browser-zen";
    desktopName = "Gaming Browser (Zen)";
    comment = "Zen for Gaming Mode (add to Steam as a non-Steam game)";
    icon = "zen-browser";
    exec = "gaming-browser zen %U";
    categories = ["Network" "WebBrowser"];
  };
in {
  environment.systemPackages = [gaming-browser desktopItem zenDesktopItem];
}
