# Desktop VMs with quickemu, plus SPICE USB redirection so USB devices can be
# passed through to a running VM.
{pkgs, ...}: {
  environment.systemPackages = [pkgs.quickemu];
  virtualisation.spiceUSBRedirection.enable = true;
}
