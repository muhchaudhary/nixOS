{
  description = "My NixOS flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVd7CNfq5E4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nix-gaming.url = "github:fufexan/nix-gaming";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";

    # System deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    blender-bin,
    ...
  } @ inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [];
      };

      overlays = with inputs; [
        blender-bin.overlays.default
        (final: prev: {
          # OpenLDAP's syncrepl test can be flaky in some environments.
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = false;
          });
        })
        (final: prev: {
          # Companion server for the MoonDeck SteamDeck plugin. Not in nixpkgs;
          # wraps upstream's prebuilt AppImage rather than building from source.
          moondeck-buddy = prev.appimageTools.wrapType2 {
            pname = "moondeck-buddy";
            version = "1.9.2";
            src = prev.fetchurl {
              url = "https://github.com/FrogTheFrog/moondeck-buddy/releases/download/v1.9.2/MoonDeckBuddy-1.9.2-x86_64.AppImage";
              hash = "sha256-SfaqrBJJZlJwhSPLPUlwfvZ8RxIWrbwY6uys8ziRvek=";
            };
            meta = {
              description = "Server-side companion for the MoonDeck SteamDeck plugin";
              homepage = "https://github.com/FrogTheFrog/moondeck-buddy";
              license = prev.lib.licenses.lgpl3Only;
              platforms = ["x86_64-linux"];
            };
          };
        })
      ];

      homes.modules = [inputs.spicetify-nix.homeManagerModules.spicetify];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nix-gaming.nixosModules.platformOptimizations
        sops-nix.nixosModules.sops
      ];

      systems.hosts.muhammadDesktop.modules = with inputs; [
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        nix-gaming.nixosModules.pipewireLowLatency
      ];

      systems.hosts.muhammadLaptop.modules = with inputs; [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen4
      ];

      systems.hosts.laptopServer.modules = with inputs; [
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-ssd
      ];

      templates = {
        devshell.description = "Simple flake dev shell.";
      };

      deploy = lib.mkDeploy {
        inherit (inputs) self;
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
