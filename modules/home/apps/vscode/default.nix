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
      nil
    ];

    programs.vscode = {
      enable = true;
      package = with pkgs;
        (vscode.override {isInsiders = true;})
        .overrideAttrs
        (prevAttrs: {
          src = builtins.fetchTarball {
            # run `curl -I https://update.code.visualstudio.com/latest/linux-x64/insider | grep location: | cut -c 11-` to get latest url
            url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/b2426c57053497e6c1eea406b8f2855e442992b4/code-insider-x64-1763733071.tar.gz";
            sha256 = "sha256:1wkq9licqf4hb64sflgslzydfvccg6d732j5yr1qv6abhzwn42iz";
          };
          version = "latest";
          buildInputs =
            prevAttrs.buildInputs or []
            ++ [
              curl
              openssl
              webkitgtk_4_1
              libsoup_3
            ];
        });
      profiles.default.extensions = with pkgs;
      with vscode-extensions; [
        kamadorueda.alejandra
        bbenoist.nix
        esbenp.prettier-vscode
        ms-python.python
        ms-python.vscode-pylance
        timonwong.shellcheck
        foxundermoon.shell-format
        eamodio.gitlens
      ];
    };
  };
}
