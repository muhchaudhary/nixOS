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
    ...
  } @ inputs: let
    system = "x86_64-linux";
    vscode-overlay = self: super: {
      vscode-fhs = super.vscode-fhs.overrideAttrs (oldAttrs: rec {
        postFixup =  ''
        patchelf --add-needed ''${libglvnd}/lib/libGL.so.1 ''$out/lib/vscode/''${executableName}; \
        '';
        commandLineArgs ="--disable-gpu-sandbox";
        preFixup = ''
        gappsWrapperArgs+=(
        # Add gio to PATH so that moving files to the trash works when not using a desktop environment
        --prefix PATH : ''${glib.bin}/bin
        --add-flags ''${lib.escapeShellArg commandLineArgs}
        )
        '';
      });
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: drvs.packages.${system})
        (final: prev: hyprland.packages.${system})
      ];
      config = {
        allowUnfree = true;
      };
    };
    args = {
      inherit pkgs;
      inherit inputs;
    };
  in {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ vscode-overlay ];
    nixosConfigurations = {
      "muhammadDesktop" = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/muhammadDesktop/configuration.nix
          {programs.hyprland.enable = true;}
          {programs.hyprland.xwayland.enable = true;}
          {programs.hyprland.enableNvidiaPatches = true;}
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
