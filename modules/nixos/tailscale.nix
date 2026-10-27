# Tailscale mesh VPN, for reaching this host from outside the home network.
# Log in once per host with `sudo tailscale up`. Anything on tailscale0 is
# trusted by the firewall, so services can listen on the tailnet without
# opening ports on the LAN.
{config, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP port for direct (non-relayed) connections
  };

  networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
}
