# Home config shared by every host; applied automatically by
# modules/nixos/home-manager.nix alongside the host's own `home.nix`.
{...}: {
  imports = [
    ./user.nix
    ./cli
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
