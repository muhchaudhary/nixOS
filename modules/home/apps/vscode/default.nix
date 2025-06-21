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
      # package = with pkgs; (vscode.override {isInsiders = true;});
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
