{
  config,
  pkgs,
  lib,
  ...
}: {
  # Make sure opengl is enabled
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver vaapiVdpau libvdpau-va-gl];
  };

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];
  nixpkgs.config.cudaSupport = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.nvidia-container-toolkit.enable = true;
}
