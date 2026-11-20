# Everything related to gaming: Steam (+ SteamOS-style Gaming Mode) + Heroic + Hookshot (OoT recomp).
# (Decky Loader is separate: hosts import `deckyLoader` by name.)
{...}: {
  imports = [
    ./steam.nix
    ./heroic.nix
    ./hookshot.nix
    ./gaming-mode.nix
  ];
}
