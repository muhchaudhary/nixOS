{pkgs, ...}: {
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
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
