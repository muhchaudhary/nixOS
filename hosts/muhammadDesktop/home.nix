{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadDesktop.nix
  ];
}
