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
  cfg = config.${namespace}.apps.communication;
in {
  options.${namespace}.apps.communication = {
    enable = mkBoolOpt false "Whether to install communication apps.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      teams-for-linux
      telegram-desktop
      vesktop
      warpinator
    ];
  };
}
