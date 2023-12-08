{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadDesktop.nix
  ];
}
../homes/muhamamdDesktop/home.nix
../homes/muhamamdDesktop/wm-${NAME}.nix
