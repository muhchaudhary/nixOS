{
  description = "my derivations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    # this won't be used 'yet' (might be useful for the future)
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: {
      aylurs-ags-dots = pkgs.callPackage ./aylurs-ags-dots.nix {};
    });
    #nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {};
    #overlays.default = final: prev: {};
  };
}
