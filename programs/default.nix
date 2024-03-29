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
  ];

  home.packages = with pkgs; [
    steam
    gamescope
    prismlauncher
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
    # latex
    texliveFull
    rstudio
    (rWrapper.override
      {
        packages = with rPackages; [
          languageserver
          rmarkdown
          ggplot2
          dplyr
          xts
          jsonlite
          aplpack
          loon
          png
          qqtest
          PairViz
        ];
      })
    gnumake
  ];

  programs.git-credential-oauth.enable = true;
}
