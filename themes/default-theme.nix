{pkgs, ...}: {
  imports = [inputs.ags.homeManagerModules.default];

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaPeach;
    name = "Catppuccin-Mocha-Peach-Cursors";
    size = 40;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    # font = {
    #   package = pkgs.nerdfonts.override {fonts = ["Mononoki"];};
    #   name = "Mononoki Nerd Font Regular";
    #   size = 18;
    # };
    # iconTheme = {
    #   package = pkgs.catppuccin-papirus-folders.override {
    #     flavor = "mocha";
    #     accent = "peach";
    #   };
    #   name = "Papirus-Dark";
    # };
    theme = {
      package = ags;
      name = "aylurs-gtk-shell";
    };
  };
}
