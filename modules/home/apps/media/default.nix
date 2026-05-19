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
  cfg = config.${namespace}.apps.media;
in {
  options.${namespace}.apps.media = {
    enable = mkBoolOpt false "Whether to install media apps.";
  };

  config = mkIf cfg.enable {
    services.mpris-proxy.enable = true;

    home.packages = with pkgs; [
      (mpv.override {scripts = [mpvScripts.mpris];})
      jellyfin-mpv-shim
      totem
    ];

    programs.spicetify.enable = true;
  };
}
