{ config, pkgs, ... }: {
  # imports = [
  
  # ];
  # home.packages = with pkgs; [

  # ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}