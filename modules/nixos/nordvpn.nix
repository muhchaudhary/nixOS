# NordVPN client (nordvpnd + CLI + GUI) via the upstream nixpkgs module.
# Log in once per host with `nordvpn login` (or `nordvpn login --token <token>`),
# then `nordvpn c [country]` / `nordvpn d`. Note: the upstream module enables
# systemd-resolved, which nordvpnd uses to set DNS.
{...}: {
  services.nordvpn.enable = true;

  # Required by NordVPN's routing with the firewall on (strict rpfilter drops tunnel replies).
  networking.firewall.checkReversePath = "loose";

  users.users.muhammad.extraGroups = ["nordvpn"];
}
