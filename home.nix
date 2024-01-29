{
  config,
  pkgs,
  lib,
  inputs,
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

  # Tools only
  home.packages = with pkgs; [
    gobject-introspection
    (python3.withPackages (ps:
      with ps; [
        inputs.fabric-test.packages.x86_64-linux.fabric
        loguru
        pycairo
        psutil
      ]))

    desktop-file-utils
    inotify-tools
    ffmpeg
    ffmpegthumbnailer
    libnotify
    killall
    wlr-randr
    #fish
    fishPlugins.tide
    xwaylandvideobridge
    networkmanagerapplet
  ];

  programs = {
    home-manager.enable = true;
  };

  # Enable use of bluetooth media buttons
  services.mpris-proxy.enable = true;
  services.blueman-applet.enable = true;
  services.network-manager-applet.enable = true;

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  home.stateVersion = "23.05";
}
