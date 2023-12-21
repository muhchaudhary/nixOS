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
    wlr-randr
    w3m
    imagemagick

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
    xdg-utils

    #fish
    fishPlugins.tide

    libsForQt5.gwenview
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };

  # Enable use of bluetooth media buttons
  services.mpris-proxy.enable = true;
  services.blueman-applet.enable = true;

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    extraConfig = "
    background_opacity 0.8
    font_family MesloLGSDZ Nerd Font
    ";
  };

  home.stateVersion = "23.05";
}
