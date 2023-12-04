{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
  ];
  programs.git-credential-oauth.enable = true;
}
