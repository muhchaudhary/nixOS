{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode.nix
    ./gnome.nix
    ./kitty.nix
    ./obsidian.nix
    ./swaylock.nix
  ];

  home.packages = with pkgs; [
    steam
    gamescope
    minecraft
    onlyoffice-bin
    kicad-small
    spotify
    jellyfin-media-player
    jellyfin-mpv-shim
    telegram-desktop
    r2modman
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    (mpv.override {scripts = [mpvScripts.mpris];})
    xdg-utils
    libsForQt5.gwenview
    openvpn
  ];

  programs.git-credential-oauth.enable = true;
}
