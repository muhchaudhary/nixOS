{ homeDirectory
, pkgs
, stateVersion
, system
, username }: 
{

  imports =
  [ 
    ./nix-programs
  ];

  home = {
    inherit homeDirectory stateVersion username;

    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };
  };

    # As already mentioned
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  nixpkgs = {
    config = {
      inherit system;
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
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

  # xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  # xdg.userDirs = {
  #   enable = true;
  #   extraConfig = {
  #     XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  #   };
  # };

  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "waybar"
      ];
    };
  };

  programs = {
    home-manager.enable = true;
    bash.enable = true;
  };
}