# Longshot (formerly Hookshot: native static recompilation of the Switch 2 Ocarina of Time
# remake). Not packaged: the upstream LongshotLauncher-*.AppImage builds the game from your own
# game files and updates itself in place, so we just make it runnable:
#
# - no appimage binfmt: the AppImage has a static runtime, so it runs as-is (FUSE via the
#   fusermount3 wrapper, or APPIMAGE_EXTRACT_AND_RUN=1 as its Steam tile sets). Its Steam tile
#   runs it inside the Steam Runtime 4 container, where binfmt's /run/binfmt/appimage_type_*
#   interpreter (appimage-run) doesn't exist, so with binfmt registered the launch fails.
# - nix-ld: the launcher (single-file .NET + Avalonia/SkiaSharp) and the built game are plain
#   glibc binaries when started from the desktop. The game ships its own SDL2 and dlopens
#   Vulkan, windowing, audio and input libraries; the launcher needs fontconfig, ICU, OpenSSL.
{pkgs, ...}: let
  runtimeLibs = with pkgs; [
    vulkan-loader
    libGL
    SDL2
    sdl3
    libdecor
    wayland
    libxkbcommon
    libx11
    libxext
    libxcursor
    libxi
    libxrandr
    libxfixes
    libxscrnsaver
    alsa-lib
    libpulseaudio
    pipewire
    udev
    dbus
    zlib
    stdenv.cc.cc.lib
    # launcher: SkiaSharp needs fontconfig; .NET dlopens ICU, OpenSSL, GSSAPI; Avalonia X11 SM
    fontconfig
    freetype
    icu
    openssl
    krb5
    libice
    libsm
  ];
in {
  # `appimage-run` stays available by hand for other AppImages; no binfmt (see above).
  programs.appimage.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = runtimeLibs;
  };

  # The builder's bundled OpenSSL looks for CAs at /etc/ssl/cert.pem (absent on NixOS), so the
  # launcher's update check fails with CERTIFICATE_VERIFY_FAILED. Point it at NixOS's bundle.
  environment.sessionVariables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

  # The game asks "Update now / Not now / Skip this version" (and the launcher reports errors)
  # through zenity; without it the question is silently skipped.
  environment.systemPackages = [pkgs.zenity];
}
