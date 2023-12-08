{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode.nix
  ];
  programs.git-credential-oauth.enable = true;
}
