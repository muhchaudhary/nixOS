{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode.nix
    ./gnome.nix
  ];

  programs.git-credential-oauth.enable = true;
}
