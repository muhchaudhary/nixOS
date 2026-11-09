# Tailscale mesh VPN, for reaching this host from outside the home network.
# Log in once per host with `sudo tailscale up`. Anything on tailscale0 is
# trusted by the firewall, so services can listen on the tailnet without
# opening ports on the LAN.
#
# Tailscale SSH (`--ssh`): tailscaled answers port 22 on the tailnet address and
# authenticates by tailnet identity, so no SSH keys are needed; who may log in as
# which user is set by the `ssh` section of the tailnet policy (admin console).
{config, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP port for direct (non-relayed) connections
    extraSetFlags = ["--ssh"];
  };

  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
}
