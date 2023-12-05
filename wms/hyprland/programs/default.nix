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
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
