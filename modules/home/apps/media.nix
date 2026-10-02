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
  ];

  programs.spicetify.enable = true;
}
