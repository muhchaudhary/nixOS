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
  xdg.configFile."ags".source = ./ags/config;
  programs.waybar.enable = true;
}
