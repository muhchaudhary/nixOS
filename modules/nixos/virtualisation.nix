# Docker. A host that needs the NVIDIA container runtime imports the `nvidia`
# module (which enables the container toolkit) and sets:
#   virtualisation.docker.extraOptions =
#     "--add-runtime nvidia=/run/current-system/sw/bin/nvidia-container-runtime";
# Desktop VMs (quickemu) are the separate `quickemu` module.
{...}: {
  users.users.muhammad.extraGroups = ["docker"];
  virtualisation.docker.enable = true;
}
