{pkgs, ...}: {
  services.udisks2.enable = true; # Required for udiskie
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;
  # NetworkManager tray applet (the `network` module itself is shared with the headless server).
  programs.nm-applet.enable = true;
  # Login: hosts import `sddm` (login screen) or `autologin` (straight into a
  # locked Hyprland session).

  # programs.kdeconnect = {
  #   enable = true;
  #   package = pkgs.kdePackages.kdeconnect-kde;
  # };

  # Hyprland binary cache (merged with the base substituters from ../nix.nix).
  nix.settings.substituters = ["https://hyprland.cachix.org"];
  nix.settings.trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
}
