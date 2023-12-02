{ config, pkgs, ... }: {
  imports = [
    ./git.nix
  ];
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  xdg.userDirs = {
    enable = true;
    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
  programs.git-credential-oauth.enable = true;
}