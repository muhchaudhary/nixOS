# Home Manager as a NixOS module, so one `nilla os switch` activates system + home.
# Every host gets the shared home base plus its own `hosts/<host>/home.nix`.
{
  inputs,
  host,
  homeModules,
  ...
}: {
  imports = [inputs.home-manager.result.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    extraSpecialArgs = {inherit inputs homeModules;};
    users.muhammad.imports = [
      homeModules.base
      (../../hosts + "/${host}/home.nix")
    ];
  };
}
