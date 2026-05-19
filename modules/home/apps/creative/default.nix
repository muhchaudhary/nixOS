{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.creative;
in {
  options.${namespace}.apps.creative = {
    enable = mkBoolOpt false "Whether to install creative apps.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inkscape
      blender_4_5
      freecad
      kicad-small
      godot_4
    ];
  };
}
