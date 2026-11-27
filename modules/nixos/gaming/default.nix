# Everything related to gaming: Steam + Heroic + Hookshot (OoT recomp).
# (Decky Loader is separate: hosts import `deckyLoader` by name.)
{...}: {
  imports = [
    ./steam.nix
    ./heroic.nix
    ./hookshot.nix
    ./gaming-browser.nix
  ];
}
