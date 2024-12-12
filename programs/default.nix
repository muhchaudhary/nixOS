{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./fastfetch.nix
    ./git.nix
    ./gnome.nix
    ./kitty.nix
    ./obsidian.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
    chromium
    steam
    gamescope
    freecad
    prismlauncher
    onlyoffice-bin
    kicad-small
    spotify
    bottles
    jellyfin-media-player
    jellyfin-mpv-shim
    telegram-desktop
    r2modman
    (discord.override {
      # withOpenASAR = true;
      withVencord = true;
    })
    (mpv.override {scripts = [mpvScripts.mpris];})
    xdg-utils
    libsForQt5.gwenview
    openvpn
    yazi
    # latex
    texliveFull

    # game dev
    godot_4
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
