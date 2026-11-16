{
  pkgs,
  config,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver libva-vdpau-driver libvdpau-va-gl];
  };

  services.xserver.videoDrivers = ["nvidia"];
  boot.initrd.kernelModules = ["nvidia"];
  boot.kernelParams = [
    "module_blacklist=nouveau"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    # Take over the console at boot instead of on the first kernel message. With
    # deferred takeover, a message printed during resume (e.g. an xHCI reinit)
    # makes fbcon take over while nvidia_resume runs from the kernel PM notifier:
    # fbcon holds console_lock and wants the nvkms lock, nvidia holds the nvkms
    # lock and wants console_lock, and the system hangs on wake.
    "fbcon=nodefer"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    # Open kernel modules: NVIDIA's recommended driver for Turing and newer (the
    # 3090 is Ampere); same userspace driver, but tracks new kernels better.
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];

  # The driver's shader cache (~/.cache/nvidia/GLCache) is capped at 1 GB and
  # evicts entries past that, so emulators (Lichii's Switch 2 pipelines) end up
  # rebuilding shaders they already compiled. Allow 10 GB and keep it.
  environment.variables = {
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };
  hardware.nvidia-container-toolkit.enable = true;
}
