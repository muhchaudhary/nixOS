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
  cfg = config.${namespace}.cli.fastfetch;
in {
  options.${namespace}.cli.fastfetch = {
    enable = mkBoolOpt false "Whether to install nix-direnv.";
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        modules = [
          # Header
          "title"
          "separator"

          # System Info
          "os"
          "host"
          "kernel"
          "packages"

          # Desktop Environment
          "de"
          "wm"

          # Shell/Terminal
          "shell"
          "terminal"

          # Hardware
          "display"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
        ];
      };
    };
  };
}
