# All GUI application modules. A host that wants only some of them imports the
# individual `homeModules.<app>` entries instead of this barrel.
{...}: {
  imports = [
    ./browsers.nix
    ./communication.nix
    ./creative.nix
    ./dev.nix
    ./general.nix
    ./kitty.nix
    ./media.nix
    ./streaming.nix
    ./vscode.nix
  ];
}
