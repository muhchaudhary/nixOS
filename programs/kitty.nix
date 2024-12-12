{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
  };
  home.packages = with pkgs; [
    w3m
  ];
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "Fira Code";
      size = 12;
    };
    settings = {
      shell = "fish";
    };
    extraConfig = "
    background_opacity 0.8
    confirm_os_window_close 0
    ";
  };
}
