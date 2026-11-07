# Serves this machine's /nix/store as a signed binary cache (Harmonia, port 5000),
# so other hosts can download what this one built (see desktop-cache.nix). Port
# 5000 isn't opened in the firewall: only the tailnet (tailscale0 is trusted) can
# reach it.
#
# The signing key is generated once on this host, outside the repo:
#   sudo mkdir -p /var/lib/secrets
#   sudo nix-store --generate-binary-cache-key muhammadDesktop-1 \
#     /var/lib/secrets/harmonia.secret /var/lib/secrets/harmonia.pub
# and the public half goes in desktop-cache.nix.
{...}: {
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = ["/var/lib/secrets/harmonia.secret"];
    # Preferred over cache.nixos.org (40) by clients; lower is tried first.
    settings.priority = 30;
  };
}
