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
            # run curl -I https://update.code.visualstudio.com/latest/linux-x64/insider to get latest url
            url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/7de43ea56b9b4bfd193263f7523ab7ad9d998d26/code-insider-x64-1758086384.tar.gz";
            sha256 = "sha256:0bnyzvhis1j6w1xjyy6g47qxy9pl735c90fiq66yrrly57sazlw9";
          };
          version = "latest";
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
