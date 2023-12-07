{
  description = "My NixOS Flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager for user configuration
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    ags.url = "github:Aylur/ags";
    drvs = {
      url = "path:./derivations";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    drvs,
    blender-bin,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      overlays = [
        (final: prev: hyprland.packages.${system})
        (final: prev: drvs.packages.${system})
        blender-bin.overlays.default
      ];

      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-24.8.6"
        ];
      };
    };
    args = {
      inherit pkgs;
      inherit inputs;
    };
  in {
    nixosConfigurations = {
      "muhammadDesktop" = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/muhammadDesktop/configuration.nix
          {programs.hyprland.enable = true;}
          {programs.hyprland.xwayland.enable = true;}
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = args;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.muhammad = import ./hosts/muhammadDesktop/home.nix;
            };
          }
        ];
      };
    };
  };
}
