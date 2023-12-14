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
    kicad-small
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    telegram-desktop
    r2modman
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    (mpv.override {scripts = [mpvScripts.mpris];})
    gnome.gnome-tweaks
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };

  # Enable use of bluetooth media buttons
  services.mpris-proxy.enable = true;
  services.blueman-applet.enable = true;

  home.stateVersion = "23.05";
}
