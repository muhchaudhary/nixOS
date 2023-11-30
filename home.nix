{ config, pkgs, lib, ... }: {

  imports =
  [ # Include the results of the hardware scan.
    ./nix-programs
  ];
  home = {
    username = "muhammad";
    homeDirectory ="/home/muhammad";
  };


  # As already mentioned
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  # The critical missing piece for me
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  xdg.userDirs = {
    enable = true;
    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager.enable = true;
    bash.enable = true;
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
  ];


  home.stateVersion = "23.05";
}