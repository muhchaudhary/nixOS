{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    w3m
  ];
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    extraConfig = "
    background_opacity 0.8
    font_family MesloLGSDZ Nerd Font
    ";
  };
}
