{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./programs
  ];

  home = {
    username = "muhammad";
    homeDirectory = "/home/muhammad";
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  xdg.userDirs = {
    enable = true;
  };

  home.packages = with pkgs; [
    desktop-file-utils
    steam
    gnome.gnome-tweaks
    (blender.override {cudaSupport = true;})
    gradience
    minecraft
    onlyoffice-bin
    kicad
    yuzu-early-access
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    waybar

    telegram-desktop
    r2modman
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
  home.stateVersion = "23.05";
}
