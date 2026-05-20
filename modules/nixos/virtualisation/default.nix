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
  cfg = config.${namespace}.virtualisation;
in {
  options.${namespace}.virtualisation = {
    enable = mkBoolOpt false "Enable everything related to virtualisation.";
    nvidia = mkBoolOpt false "Enable NVIDIA container runtime for Docker.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      ${namespace}.user.extraGroups = ["docker"];
      virtualisation.docker.enable = true;

      environment.systemPackages = with pkgs; [
        quickemu
      ];
      virtualisation.spiceUSBRedirection.enable = true;
    }
    (mkIf cfg.nvidia {
      virtualisation.docker.extraOptions = "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
      hardware.nvidia-container-toolkit.enable = true;
    })
  ]);
}
