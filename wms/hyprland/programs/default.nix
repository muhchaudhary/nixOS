{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ags.nix
  ];
  home.packages = with pkgs; [
    wofi
    btop
    swww
    sassc
    wl-clipboard
    wf-recorder
    brightnessctl
    hyprpicker
    wayshot
    pavucontrol
    swappy
    slurp
    imagemagick
    libdbusmenu-gtk3
  ];

  #  xdg.configFile."waybar".source = ./waybar;
  #  programs.waybar.enable = true;
}
