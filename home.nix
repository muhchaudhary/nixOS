{ homeDirectory, pkgs, stateVersion, system, username }: {
  imports =
  [ 
    ./programs
    ./hyprland-conf
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

  home.packages = with (pkgs); [
    desktop-file-utils
    steam
    gnome.gnome-tweaks
    (blender.override {cudaSupport = true;})
    gradience
    minecraft
    onlyoffice-bin
    kicad
    yuzu-early-access
    vscode-fhs
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    waybar
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
}