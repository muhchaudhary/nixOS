{
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./ags.nix
    ./hyprlock.nix
    ./hypridle.nix
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
    hyprpaper
    grimblast
    pavucontrol
    swappy
    slurp
    imagemagick
    libdbusmenu-gtk3
  ];
}
