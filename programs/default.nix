{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode.nix
  ];
  home.packages = with pkgs; [
    gnome.nautilus
  ];

  programs.git-credential-oauth.enable = true;
}
