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
    desktop.hyprland = enabled;
    hardware.nvidia = enabled;
    desktop.fonts = enabled;
    themes.gtk = enabled;
    polkit = enabled;
    virtualisation = enabled;
  };

  environment.systemPackages = with pkgs; [
    spice-gtk
    r2modman
    lm_sensors
    quickemu
  ];

  environment.variables = rec {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  services.udev.extraRules = ''
    # Bose PIDs

    # All devices tested so far, normal mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="05a7", ATTRS{idProduct}=="40fe", TAG+="uaccess"

    # SoundLink Color II, DFU mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="05a7", ATTRS{idProduct}=="400d", TAG+="uaccess"

    # SoundLink Mini II, DFU mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="05a7", ATTRS{idProduct}=="4009", TAG+="uaccess"

    # QuietComfort 35 II, DFU mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="05a7", ATTRS{idProduct}=="4020", TAG+="uaccess"

    # QuietComfort 45 , DFU mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="05a7", ATTRS{idProduct}=="4039", TAG+="uaccess"
  '';

  services.xserver.wacom.enable = true;

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
