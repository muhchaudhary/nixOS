# Everything a GUI host shares on top of the home `base`: apps, infra tooling,
# GTK theme and the Hyprland desktop. Host-specific bits stay in hosts/<host>/.
{...}: {
  imports = [
    ../apps
    ../cli/infra.nix
    ../gtk.nix
    ../hyprland
  ];
}
