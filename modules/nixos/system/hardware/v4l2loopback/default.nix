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
  cfg = config.${namespace}.hardware.v4l2loopback;
in {
  options.${namespace}.hardware.v4l2loopback = {
    enable = mkBoolOpt false "Whether to enable v4l2loopback virtual camera kernel module.";
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    boot.kernelModules = ["v4l2loopback"];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="DroidCam" exclusive_caps=1
    '';
  };
}
