{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadDesktop.nix
  ];

  ## add desktop specific packages here
  home.packages = with pkgs; [
    blender
    yuzu-early-access
  ];
}
