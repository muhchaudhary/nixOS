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
    # Native Rust Spotify client (librespot). Disabled until it has a Cachix cache —
    # without one it builds from source on every bump.
    # inputs.spotifast.result.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.cava.enable = true;
}
