{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gtk3
    cairo
    gtk-layer-shell
    gobject-introspection
    pkgconf
  ];
}
