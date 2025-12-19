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
  cfg = config.${namespace}.hardware.nvidia;
in {
  options.${namespace}.hardware.nvidia = {
    enable = mkBoolOpt false "Whether to enable nvidia configuration.";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver libva-vdpau-driver libvdpau-va-gl];
    };

    # NVIDIA drivers are unfree.
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
      ];
    nixpkgs.config.cudaSupport = true;

    services.xserver.videoDrivers = ["nvidia"];
    boot.initrd.kernelModules = ["nvidia"];
    boot.kernelParams = [
      "module_blacklist=nouveau"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    environment.systemPackages = with pkgs; [
      cudaPackages.cudatoolkit
    ];
    nixpkgs.config.nvidia.acceptLicense = true;
    hardware.nvidia-container-toolkit.enable = true;
  };
}
