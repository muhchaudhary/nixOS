{
  lib,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
with lib;
with lib.internal; {
  imports = [
    ./hardware.nix
  ];

  boot.kernelParams = ["module_blacklist=nouveau" "nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  internal = {
    system = enabled;
    gaming = enabled;
    # development = enabled;
    desktop.hyprland = enabled;
    hardware.nvidia = enabled;
    polkit = enabled;
  };

  environment.systemPackages = with pkgs; [
    r2modman
    lm_sensors
  ];

  environment.variables = rec {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
  };

  services = {
    sunshine.enable = true;
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
    pipewire.lowLatency = {
      enable = true;
      quantum = 32;
      rate = 48000;
    };
  };

  security.rtkit = enabled;

  nix.settings = {
    cores = 8;
    max-jobs = 8;
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
