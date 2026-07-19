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
  cfg = config.${namespace}.apps.streaming;
in {
  options.${namespace}.apps.streaming = {
    enable = mkBoolOpt false "Whether to install streaming apps.";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [droidcam-obs];
    };

    home.packages = [pkgs.droidcam];
  };
}
