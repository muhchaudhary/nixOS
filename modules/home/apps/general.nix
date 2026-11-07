{pkgs, ...}: {
  home.packages = with pkgs; [
    nautilus
    gnome-calculator
    gnome-system-monitor
    obsidian
    # libreoffice-qt
    kdePackages.gwenview
    transmission_4-gtk
    transmission-remote-gtk

    (prismlauncher.override {
      jdks = [openjdk25];
    })
  ];
}
