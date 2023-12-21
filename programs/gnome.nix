# include all gnome programs here
{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs.gnome; [
    gnome-tweaks
    nautilus
    gnome-system-monitor
  ];
}
