{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ags.nix
    ./swaylock.nix
    ./swayidle.nix
    ./gtkFabric.nix
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
}
