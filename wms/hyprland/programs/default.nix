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
    killall
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
