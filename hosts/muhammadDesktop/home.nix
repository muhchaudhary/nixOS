# Home Manager config for this host, on top of the home `base` (applied to every
# host automatically). Host-only apps and overrides go here.
{homeModules, ...}: {
  imports = with homeModules; [
    workstation
    ./hyprland.nix
  ];
}
