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
  # The status bar regenerates ~/.config/gtk-4.0/gtk.css at runtime, so HM's
  # managed file collides with it on activation. Force HM to overwrite instead
  # of failing on the backup step.
  xdg.configFile."gtk-4.0/gtk.css".force = true;
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
