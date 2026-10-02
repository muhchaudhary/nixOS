# Applied to every host by `generators.nixos.modules` in nilla.nix: nix daemon
# settings, the muhammad user, and Home Manager.
{...}: {
  imports = [
    ./nix.nix
    ./user.nix
    ./home-manager.nix
    ./nilla.nix
  ];
}
