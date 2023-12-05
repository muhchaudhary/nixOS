{
  config,
  pkgs,
  ...
}: {
  # imports = [

  # ];
  home.packages = with pkgs; [
    waybar
    wofi
    btop
    killall
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
