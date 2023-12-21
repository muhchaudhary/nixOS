{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode.nix
    ./gnome.nix
    ./neovim.nix
  ];

  programs.git-credential-oauth.enable = true;
}
