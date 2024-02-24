{
  config,
  pkgs,
  ...
}: {
  #import specific hyprland programs
  imports = [
    ./gtk.nix
  ];

  programs.pywal.enable = true;
}
