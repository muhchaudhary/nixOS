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
  cfg = config.${namespace}.cli.infra;
in {
  options.${namespace}.cli.infra = {
    enable = mkBoolOpt false "Whether to install IaC and infra management tools.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      k9s
      dive
    ];
  };
}
