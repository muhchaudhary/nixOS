{
  description = "My NixOS Flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager for user configuration
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  }; 
  outputs = { self 
              , nixpkgs 
              , home-manager
              , ... }@inputs: let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
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
          home-manager.nixosModules.home-manager {
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