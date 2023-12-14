{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ags.nix
  ];
  home.packages = with pkgs; [
    # waybar
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
    upower
  ];

  xdg.configFile."waybar".source = ./waybar;
  programs.waybar.enable = true;
}
