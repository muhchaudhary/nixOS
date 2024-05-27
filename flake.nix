{
  description = "My NixOS Flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    # home-manager for user configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    hyprland,
    blender-bin,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      overlays = [
        blender-bin.overlays.default
        # hyprland.overlays.default
      ];

      config = {
        allowUnfree = true;
      };
    };
    args = {
      inherit self;
      inherit pkgs;
      inherit inputs;
    };
  in {
    nixosConfigurations = {
      "muhammadDesktop" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/muhammadDesktop/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
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
      "muhammadLaptop" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/muhammadLaptop/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = args;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.muhammad = import ./hosts/muhammadLaptop/home.nix;
            };
          }
        ];
      };
    };
  };
}
