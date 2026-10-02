{pkgs, ...}: {
  home.packages = with pkgs; [
    # hyprland-qtutils from nixpkgs (matches the upstream flake's 0.1.5); avoids
    # pulling the flake's transitive Hyprland inputs through Nilla's loader.
    hyprland-qtutils

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
