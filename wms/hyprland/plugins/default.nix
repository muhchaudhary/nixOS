{
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./hyprexpo.nix
    ./hyprspace.nix
  ];
}
