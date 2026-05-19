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
  cfg = config.${namespace}.apps.browsers;
in {
  options.${namespace}.apps.browsers = {
    enable = mkBoolOpt false "Whether to install browsers.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      chromium
    ];
  };
}
