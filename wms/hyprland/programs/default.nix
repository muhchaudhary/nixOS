{
  config,
  pkgs,
  ...
}: {
  # imports = [

  # ];
  home.packages = with pkgs; [
    wofi
    btop
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
