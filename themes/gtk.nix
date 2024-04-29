{pkgs, ...}: {
  home.pointerCursor = {
    package = pkgs.apple-cursor;
    name = "macOS-Monterey";
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.kora-icon-theme;
      name = "kora";
    };
    theme = {
      package = pkgs.colloid-gtk-theme.override {
        tweaks = [
          "black"
          "rimless"
        ];
      };
      name = "Colloid-Dark";
    };
  };
}
