{
  pkgs,
  config,
  ...
}: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
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
    gtk4.theme = config.gtk.theme;
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "adwaita";
  };
  dconf.enable = true;
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };
}
