{
  config,
  pkgs,
  ...
}: {
  #import specific hyprland programs
  imports = [
    ./gtk.nix
  ];
}
