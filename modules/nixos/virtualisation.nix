# Base virtualisation stack: Docker + quickemu. A host that needs the NVIDIA
# container runtime imports the `nvidia` module (which enables the
# container toolkit) and sets:
#   virtualisation.docker.extraOptions =
#     "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
{pkgs, ...}: {
  users.users.muhammad.extraGroups = ["docker"];
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    quickemu
  ];
  virtualisation.spiceUSBRedirection.enable = true;
}
