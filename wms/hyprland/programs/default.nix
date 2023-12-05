{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ags
  ];
  home.packages = with pkgs; [
    waybar
    wofi
    btop
    killall
    swww
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
