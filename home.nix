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
    # tools
    desktop-file-utils
    inotify-tools
    ffmpeg
    libnotify
    killall

    steam
    gamescope
    minecraft
    onlyoffice-bin
    kicad
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
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
