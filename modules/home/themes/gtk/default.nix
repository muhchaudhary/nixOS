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
  cfg = config.${namespace}.themes.gtk;
in {
  options.${namespace}.themes.gtk = with types; {
    enable = mkBoolOpt false "Whether to enable catppuccin user theme";
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
    };

    home.sessionVariables = {
      HYPRCURSOR_THEME = "Bibata-Modern-Classic";
      HYPRCURSOR_SIZE = "24";
    };

    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.kora-icon-theme;
        name = "kora";
      };
      theme = {
        package = pkgs.colloid-gtk-theme.override {
          tweaks = [
            "black"
            "rimless"
          ];
        };
        name = "Colloid-Dark";
      };
    };
    qt.enable = true;
    qt.style.name = "kvantum";
    qt.platformTheme.name = "kvantum";
  };
}
