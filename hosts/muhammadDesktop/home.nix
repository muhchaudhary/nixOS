# Home Manager config for this host, on top of the home `base` (applied to every
# host automatically). Host-only apps and overrides go here.
{
  pkgs,
  homeModules,
  ...
}: {
  imports = with homeModules; [
    workstation
    ./hyprland.nix
  ];

  # Coding agent for the local llama-swap server (~/Documents/LLMs)
  home.packages = [pkgs.qwen-code];
}
