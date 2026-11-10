# Hookshot (native static recompilation of the Switch 2 Ocarina of Time remake).
# Not packaged: the upstream AppImage is a builder that compiles the game from your own
# game files into ~/Games/Hookshot and updates it in place, so we just make it runnable:
#
# - appimage binfmt: the downloaded Hookshot-*.AppImage (and its bundled Python/clang)
#   runs directly, inside appimage-run's FHS env. The launcher calls back into it to update.
# - nix-ld: the built game (~/Games/Hookshot/hookshot, bin/hookshot) is a plain glibc
#   binary, started from the "Hookshot" menu entry the builder writes, outside any FHS env.
#   It ships its own SDL2 and dlopens Vulkan, windowing, audio and input libraries.
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
  ];
in {
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [pkgs.libgpg-error pkgs.libdecor pkgs.sdl3];
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = runtimeLibs;
  };
}
