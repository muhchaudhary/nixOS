{
  pkgs,
  inputs,
  ...
}: {
  # Provides programs.spicetify.
  imports = [inputs.spicetify-nix.result.homeManagerModules.spicetify];

  services.mpris-proxy.enable = true;

  home.packages = with pkgs; [
    (mpv.override {scripts = [mpvScripts.mpris];})
    jellyfin-mpv-shim
    totem
    cheese
    # Native Rust Spotify client (librespot); no binary cache, builds from source.
    inputs.spotifast.result.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.spicetify.enable = true;

  programs.cava.enable = true;
}
