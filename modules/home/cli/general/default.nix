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
  cfg = config.${namespace}.cli.general;
in {
  options.${namespace}.cli.general = {
    enable = mkBoolOpt false "Whether to install general cli apps.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-utils
      yazi
      btop # terminal process viewer/manager
      w3m
    ];
  };
}
