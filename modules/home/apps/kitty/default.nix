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
  cfg = config.${namespace}.apps.kitty;
in {
  options.${namespace}.apps.kitty = {
    enable = mkBoolOpt false "Whether to enable kitty configuration.";
  };
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };
    programs.kitty = {
      enable = true;

      shellIntegration.enableFishIntegration = true;
      font = {
        name = "Fira Code";
        size = 12;
      };
      settings = {
        shell = "fish";
      };
      extraConfig = "
        background_opacity 0.8
        confirm_os_window_close 0
    ";
    };
  };
}
