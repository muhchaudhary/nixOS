{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode-nvfix.nix
  ];
  programs.git-credential-oauth.enable = true;
}
