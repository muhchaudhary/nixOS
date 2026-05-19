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
  cfg = config.${namespace}.apps.dev;
in {
  options.${namespace}.apps.dev = {
    enable = mkBoolOpt false "Whether to install dev tools.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zed-editor-fhs
      nixd
      claude-code
      claude-monitor
      python3
      ffmpeg
      ffmpegthumbnailer
      inotify-tools
      desktop-file-utils
      wlr-randr
    ];
  };
}
