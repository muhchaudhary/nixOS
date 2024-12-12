{
  lib,
  pkgs,
  inputs,
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.vscode;
in {
  options.${namespace}.apps.vscode = {
    enable = mkBoolOpt false "Whether to enable vscode configuration.";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alejandra
      ruff
    ];

    programs.vscode = {
      enable = true;
      package = with pkgs;
        (vscode.override {isInsiders = true;})
        .overrideAttrs
        (prevAttrs: {
          src = builtins.fetchTarball {
            # run curl -I https://update.code.visualstudio.com/latest/linux-x64/insider to get latest url
            url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/079df18bc89a113d831a43fa36c2f472136d5b40/code-insider-x64-1733948236.tar.gz";
            sha256 = "sha256:07yzkh2al8hr33nwpkhbbb5h5x63ybi3zfqr72dlivlbl747vn41";
          };
          version = "latest";
        });
      extensions = with pkgs;
      with vscode-extensions;
        [
          kamadorueda.alejandra
          bbenoist.nix
          esbenp.prettier-vscode
          ms-python.python
          ms-python.vscode-pylance
          timonwong.shellcheck
          foxundermoon.shell-format
          eamodio.gitlens
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "popping-and-locking-vscode-black";
            publisher = "philsinatra";
            version = "1.1.7";
            sha256 = "sha256-D05Bqoahrd+r57/GhbDbBeaWmZ4vTByK+P8UmyYNVR0=";
          }
          {
            name = "showtime";
            publisher = "AlexFromXD";
            version = "0.0.3";
            sha256 = "sha256-MJ24fs0qzdWLi6anaI60AufwzlQ2Sx5NFsHb6NJ/wX8=";
          }
        ];
    };
  };
}
