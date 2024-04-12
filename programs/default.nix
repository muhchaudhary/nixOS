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
    chromium
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
          Hmisc
          tidytable
          eikosograms
          venneuler
          languageserver
          rmarkdown
          ggplot2
          dplyr
          xts
          jsonlite
          aplpack
          loon
          loon_data
          png
          qqtest
          PairViz
          hexbin
          qrmdata
          devtools
          colorspace
          jpeg
          tiff
        ];
      })
    gnumake
  ];

  programs.git-credential-oauth.enable = true;

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };
}
