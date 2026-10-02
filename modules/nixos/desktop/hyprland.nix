{pkgs, ...}: {
  services.udisks2.enable = true; # Required for udiskie
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprlock.enable = true;
  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      sddm-astronaut
    ];
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    enableHidpi = true;
    settings = {
      General = {
        DisplayServer = "wayland";
      };
    };
  };

  # To make Hyprland the default session, a host sets:
  #   services.displayManager.defaultSession = "hyprland-uwsm";

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
