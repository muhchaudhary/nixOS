# A web browser for Gaming Mode (gaming-session.nix): `gaming-browser [args/URLs…]`,
# Chromium, added to Steam once as a non-Steam game ("Add a Non-Steam Game" →
# "Gaming Browser"; it syncs into Gaming Mode), with Steam Input's "Web
# Browser" controller template. Extra arguments go to Chromium, e.g. a shortcut
# running `gaming-browser --kiosk https://example.org` for a single-site "app".
#
# - --disable-gpu-sandbox: Steam preloads its overlay (gameoverlayrenderer.so)
#   into everything it launches; its glXSwapBuffers hook makes a syscall the
#   GPU process's seccomp sandbox forbids, so every frame crashed it (black
#   screen for ~1 min until Chromium fell back to software). SteamOS's Flatpak
#   Chrome never gets the overlay injected; here it loads and works instead.
#   The renderer sandboxes (the ones that face web content) stay on.
# - X11 only: opens in gamescope's Xwayland like a game, whatever
#   NIXOS_OZONE_WL says (Wayland would need gamescope's own socket).
# - Own profile (~/.local/share/gaming-browser/chromium): with the desktop's
#   profile, an already running desktop browser would get the request and open
#   the window on the desktop; it also keeps the TV session apart.
# - Window sized to gamescope's screen (no window manager there to maximize
#   it; size from gaming-session-run's GAMING_MODE_OUTPUT), and scaled for the couch:
#   1.25× at 1080p, 2.5× at 4K (the window size is in scaled pixels, so it's
#   divided by the scale). Bigger cursor (XCURSOR_SIZE, times that scale):
#   gamescope doesn't scale cursors itself.
{pkgs, ...}: let
  gaming-browser = pkgs.writeShellApplication {
    name = "gaming-browser";
    runtimeInputs = [pkgs.coreutils pkgs.gawk pkgs.xdpyinfo pkgs.chromium];
    text = builtins.readFile ./scripts/gaming-browser.sh;
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "gaming-browser";
    desktopName = "Gaming Browser";
    comment = "Web browser for Gaming Mode (add to Steam as a non-Steam game)";
    icon = "web-browser";
    exec = "gaming-browser %U";
    categories = ["Network" "WebBrowser"];
  };
in {
  environment.systemPackages = [gaming-browser desktopItem];
}
