# SDDM login screen (astronaut theme), Hyprland (UWSM) as the default session.
{pkgs, ...}: {
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
  services.displayManager.defaultSession = "hyprland-uwsm";
}
