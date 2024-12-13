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
  cfg = config.${namespace}.desktop.fonts;
in {
  options.${namespace}.desktop.fonts = with types; {
    enable = mkBoolOpt config.${namespace}.themes.gtk.enable "Whether to enable catppuccin font theming";
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      roboto
      roboto-mono
      roboto-slab
      jetbrains-mono
      league-spartan
      jost

      nerd-fonts.fira-code
      nerd-fonts.hasklug
      nerd-fonts.iosevka
      nerd-fonts.victor-mono
    ];
  };
}
