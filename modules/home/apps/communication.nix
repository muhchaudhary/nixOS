{pkgs, ...}: {
  home.packages = with pkgs; [
    teams-for-linux
    telegram-desktop
    vesktop
    warpinator
  ];
}
