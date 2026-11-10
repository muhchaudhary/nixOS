# Lichii (Switch/Switch 2 emulator, an Eden fork) from its upstream x86_64 PGO AppImage.
# Pinned by npins as a mutable URL tracking the latest release: `npins update lichii`.
# npins stores GitHub's signed asset URL, which expires ~1h after the update, so the
# stable latest-release URL is the fallback (it matches the hash until the next release).
{
  pkgs,
  lib,
  ...
}: let
  pin = (lib.importJSON ../../../npins/sources.json).pins.lichii;
  pname = "lichii";
  version = "latest";
  src = pkgs.fetchurl {
    name = "lichii-linux-x86_64-pgo.AppImage";
    urls = [pin.url pin.update_url];
    inherit (pin) hash;
  };
  extracted = pkgs.appimageTools.extract {inherit pname version src;};
  id = "io.github.zortos293.lichii";

  lichii = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    # Not bundled and not in appimageTools' default FHS env: libgpg-error is a hard
    # dependency of the bundled libgcrypt; libdecor is SDL's Wayland window decorations.
    extraPkgs = pkgs: [pkgs.libgpg-error pkgs.libdecor];
    # The session-wide Adwaita Qt theme (modules/home/gtk.nix) isn't available to the
    # AppImage's bundled Qt; clear it so Lichii uses its own themes without warnings.
    profile = ''
      unset QT_STYLE_OVERRIDE QT_QPA_PLATFORMTHEME
    '';
    extraInstallCommands = ''
      install -Dm444 ${extracted}/${id}.desktop -t $out/share/applications
      install -Dm444 ${extracted}/usr/share/icons/hicolor/256x256/apps/${id}.png \
        -t $out/share/icons/hicolor/256x256/apps
    '';
    meta = {
      description = "Experimental Nintendo Switch and Switch 2 emulator";
      homepage = "https://github.com/zortos293/Lichii";
      license = lib.licenses.gpl3Plus;
      mainProgram = "lichii";
      platforms = ["x86_64-linux"];
    };
  };
in {
  environment.systemPackages = [lichii];
}
