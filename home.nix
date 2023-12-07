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
    gamescope
    gnome.gnome-tweaks
    blender_4_0
    gradience
    minecraft
    onlyoffice-bin
    kicad
    yuzu-early-access
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    #aylurs-ags-dots
    telegram-desktop
    r2modman
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
  home.stateVersion = "23.05";
}
