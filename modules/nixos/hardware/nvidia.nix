{
  lib,
  pkgs,
  config,
  ...
}: {
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
      "cuda_cudart"
      "libcublas"
      "libcurand"
      "libcufft"
      "cudnn"
    ];
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
}
