# Gaming Mode on Nvidia: transparent Steam overlays (guide-button sidebar,
# notifications, the Home screen over a running game).
#
# Steam's UI (the steamwebhelper browser process) composites its windows with
# its own GL compositor, which needs GLX_EXT_texture_from_pixmap. Nvidia's GLX
# doesn't offer it under gamescope's Xwayland, so Steam falls back to plain X
# windows, drawn over opaque black boxes (webhelper.txt: "GLX_EXT_texture_from_pixmap
# extension unavailable ... Falling back to system composer"; gamescope #2171).
#
# EGPU-Buddy's libegpu-steam-ui.so (the `egpu-buddy` pin, frozen: it's preloaded
# into Steam) supplies the extension: each window's buffer is taken over DRI3,
# copied with Vulkan on the GPU into a texture shared with GL, then into Steam's
# texture. It only steps in inside the steamwebhelper browser process with
# EGPU_TFP=1, passes through where the GLX already has the extension, and drops
# itself from LD_PRELOAD in game launches. Log:
# ~/.local/state/nv-egpu-buddy/steam-ui-fix.log. It needs Steam's "GPU accelerated
# rendering in web views" (Settings > Display / Interface) left on.
#
# Only Gaming Mode loads it: gaming-session-run sources /etc/gaming-mode/env, whose
# STEAM_EXTRA_LD_PRELOAD the Steam wrapper's profile puts in front of its own
# LD_PRELOAD (the wrapper sets LD_PRELOAD for extest, overwriting the caller's).
# `$PLATFORM` (expanded by ld.so, and by pressure-vessel in Steam's runtime
# container) picks x86_64/ or the empty i686/ stub, so 32-bit programs load nothing.
{
  inputs,
  pkgs,
  ...
}: let
  src = inputs.egpu-buddy.src;

  steam-ui-fix = pkgs.stdenv.mkDerivation {
    pname = "egpu-steam-ui";
    version = builtins.substring 0 7 (builtins.readFile "${src}/VERSION");
    src = "${src}/packaging/steam-ui-fix";
    # Its GPU path freed the Vulkan memory under a GL texture while Steam's GL
    # copy out of it could still be queued (window resized, e.g. its menu
    # overlay after a game exits): Steam's GPU process then spun in the Nvidia
    # driver and the Big Picture UI hung. glFinish before freeing, never free
    # under another context, wait for its own blit.
    patches = [./egpu-steam-ui-gl-sync.patch];
    buildInputs = with pkgs; [libxcb libx11 libxdamage libxfixes libglvnd vulkan-headers];
    buildPhase = ''
      runHook preBuild
      $CC -O2 -fPIC -shared -Wall -Wno-misleading-indentation -Wno-nonnull-compare -Wno-missing-braces \
        -Wl,--as-needed -o libegpu-steam-ui.so egpu-steam-ui.c \
        -lxcb -lxcb-shm -lxcb-dri3 -lXdamage -lXfixes -lX11 -ldl -lpthread
      ${pkgs.pkgsi686Linux.stdenv.cc}/bin/cc -O2 -fPIC -shared -o libegpu-steam-ui-stub32.so stub32.c
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      install -Dm755 libegpu-steam-ui.so $out/lib/x86_64/libegpu-steam-ui.so
      install -Dm755 libegpu-steam-ui-stub32.so $out/lib/i686/libegpu-steam-ui.so
      runHook postInstall
    '';
    meta.license = pkgs.lib.licenses.mit;
  };
in {
  environment.etc."gaming-mode/env".text = ''
    mkdir -p "$HOME/.local/state/nv-egpu-buddy"
    export EGPU_TFP=1
    export STEAM_EXTRA_LD_PRELOAD='${steam-ui-fix}/lib/$PLATFORM/libegpu-steam-ui.so'
  '';

  programs.steam.package = pkgs.steam.override {
    extraProfile = ''
      if [ -n "''${STEAM_EXTRA_LD_PRELOAD:-}" ]; then
        export LD_PRELOAD="$STEAM_EXTRA_LD_PRELOAD''${LD_PRELOAD:+:$LD_PRELOAD}"
      fi
    '';
  };
}
