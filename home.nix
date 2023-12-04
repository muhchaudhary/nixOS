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
  # THIS DOESNT WORK BRUH
  #   vscode-fhs = pkgs.vscode-fhs.overrideAttrs (oldAttrs: rec {
  #       postFixup = oldAttrs.postFixup + ''
  #       patchelf --add-needed ''${libglvnd}/lib/libGL.so.1 ''$out/lib/vscode/''${executableName}
  #       '';
  #       commandLineArgs = "--disable-gpu-sandbox";
  #   });
    
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
    wlxoverlay
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    waybar
  ];

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
  home.stateVersion = "23.05";
}
