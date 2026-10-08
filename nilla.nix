let
  pins = import ./npins;

  nilla = import pins.nilla;
in
  nilla.create ({config, ...}: {
    includes = ["${pins.nilla-utils}/modules"];

    config = {
      ############
      ## Inputs ##
      ############
      # Every npin becomes a Nilla input under its pinned name. Flakes expose their
      # outputs under `.result`; the nixpkgs channel exposes `.result.<system>`.
      # blender-bin is defined by hand below (the generator's `src` can't be overridden).
      generators.inputs.pins = builtins.removeAttrs pins ["blender-bin"];

      inputs = {
        # The channel is pinned as "nixos-unstable"; expose it as the conventional
        # "nixpkgs" input that nilla-utils uses to build systems.
        nixpkgs = {
          src = pins.nixos-unstable;
          settings = {
            configuration = {
              allowUnfree = true;
              permittedInsecurePackages = [];
            };
            overlays = [
              config.inputs.blender-bin.result.overlays.default
              # NOTE: overlays/openldap.nix (doCheck = false) is intentionally NOT
              # applied — it changes openldap's hash and forces the entire KDE/kio
              # stack (SDDM, portal-kde, gwenview deps) to rebuild from source
              # instead of being fetched from cache. Re-add `(import ./overlays/openldap.nix)`
              # here only if you actually need to build openldap locally and hit its flaky test.
            ];
          };
        };

        # blender-bin's flake lives in the `blender` subdirectory of edolstra/nix-warez.
        blender-bin.src = pins.blender-bin + "/blender";
      };

      ###########
      ## NixOS ##
      ###########
      # Every `hosts/<name>/configuration.nix` becomes `systems.nixos.<name>`, with
      # `networking.hostName = <name>` and the `inputs`, `host`, `nixosModules` and
      # `homeModules` special args. `base` is applied to every host.
      generators.nixos = {
        folder = ./hosts;
        args.homeModules = config.modules.home;
        modules = [config.modules.nixos.base];
      };

      # Named NixOS modules. Hosts import these by name via the `nixosModules` arg;
      # modules refer to each other by relative path.
      modules.nixos = {
        base = ./modules/nixos/base.nix;

        system = ./modules/nixos/system;
        boot = ./modules/nixos/system/boot.nix;
        locale = ./modules/nixos/system/locale.nix;

        bluetooth = ./modules/nixos/hardware/bluetooth.nix;
        network = ./modules/nixos/hardware/network.nix;
        nvidia = ./modules/nixos/hardware/nvidia.nix;
        printer = ./modules/nixos/hardware/printer.nix;
        sound = ./modules/nixos/hardware/sound.nix;
        v4l2loopback = ./modules/nixos/hardware/v4l2loopback.nix;

        hyprland = ./modules/nixos/desktop/hyprland.nix;
        fonts = ./modules/nixos/desktop/fonts.nix;
        polkit = ./modules/nixos/desktop/polkit.nix;
        gtk = ./modules/nixos/gtk.nix;

        gaming = ./modules/nixos/gaming;
        steam = ./modules/nixos/gaming/steam.nix;
        heroic = ./modules/nixos/gaming/heroic.nix;

        secrets = ./modules/nixos/secrets.nix;
        virtualisation = ./modules/nixos/virtualisation.nix;
        wgHotspot = ./modules/nixos/wg-hotspot.nix;
      };

      ##################
      ## Home Manager ##
      ##################
      # Home Manager runs as a NixOS module (see modules/nixos/home-manager.nix), so
      # there is no `generators.home`. Each host's `home.nix` imports these by name
      # via the `homeModules` arg; `base` is applied to every host.
      modules.home = {
        base = ./modules/home/base.nix;
        workstation = ./modules/home/profiles/workstation.nix;

        cli = ./modules/home/cli;
        infra = ./modules/home/cli/infra.nix;

        apps = ./modules/home/apps;
        browsers = ./modules/home/apps/browsers.nix;
        communication = ./modules/home/apps/communication.nix;
        creative = ./modules/home/apps/creative.nix;
        dev = ./modules/home/apps/dev.nix;
        general = ./modules/home/apps/general.nix;
        kitty = ./modules/home/apps/kitty.nix;
        media = ./modules/home/apps/media.nix;
        streaming = ./modules/home/apps/streaming.nix;
        vscode = ./modules/home/apps/vscode.nix;

        hyprland = ./modules/home/hyprland;
        gtk = ./modules/home/gtk.nix;
      };

      ##########
      ## Misc ##
      ##########
      # A convenience package that builds every declared NixOS system at once
      # (`nilla build allSystems`), handy for CI / `nix flake check`-style gating.
      packages.allSystems = {
        systems = ["x86_64-linux"];
        package = {stdenv}:
          stdenv.mkDerivation {
            name = "all-systems";
            dontUnpack = true;
            buildPhase =
              ''
                mkdir -p $out
              ''
              + builtins.concatStringsSep "\n" (
                builtins.attrValues (
                  builtins.mapAttrs (
                    name: value: ''ln -s "${value.result.config.system.build.toplevel}" "$out/${name}"''
                  )
                  config.systems.nixos
                )
              );
          };
      };
    };
  })
