# Companion server for the MoonDeck SteamDeck plugin. Not in nixpkgs;
# wraps upstream's prebuilt AppImage rather than building from source.
{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 {
  pname = "moondeck-buddy";
  version = "1.9.2";
  src = fetchurl {
    url = "https://github.com/FrogTheFrog/moondeck-buddy/releases/download/v1.9.2/MoonDeckBuddy-1.9.2-x86_64.AppImage";
    hash = "sha256-SfaqrBJJZlJwhSPLPUlwfvZ8RxIWrbwY6uys8ziRvek=";
  };
  meta = {
    description = "Server-side companion for the MoonDeck SteamDeck plugin";
    homepage = "https://github.com/FrogTheFrog/moondeck-buddy";
    license = lib.licenses.lgpl3Only;
    platforms = ["x86_64-linux"];
  };
}
