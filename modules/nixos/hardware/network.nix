{lib, ...}: {
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  programs.nm-applet.enable = true;

  # Enable automatic timezone updates
  services.automatic-timezoned.enable = true;
  # Force enable required geoclue2 DemoAgent, since GNOME disables it: https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-1484030107
  services.geoclue2.enableDemoAgent = lib.mkForce true;
  # Use beacondb.net since Mozilla Location Service is retired: https://github.com/NixOS/nixpkgs/issues/321121
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

  users.users.muhammad.extraGroups = ["networkmanager" "dialout"];
}
