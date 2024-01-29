{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home.nix
    ../../wms/hyprland/muhammadDesktop.nix
  ];

  ## add desktop specific packages here
  home.packages = with pkgs; [
    blender
    yuzu-early-access
  ];

  # vscode nvidia fix
  programs.vscode.package = with pkgs;
    (pkgs.vscode.override {isInsiders = true;})
    .overrideAttrs
    (prevAttrs: {
      src = builtins.fetchTarball {
        # run curl -I https://update.code.visualstudio.com/latest/linux-x64/insider to get latest url
        url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/800e60abdfb1675a59520bac6a9473bc380d49ea/code-insider-x64-1705990311.tar.gz";
        sha256 = "0bigwz1izaafrijsg6mmnjxcdwfzhhwd5i60d79cj92h3qli1h44";
        #sha256 = lib.fakeSha256;
      };
      preFixup = ''
        gappsWrapperArgs+=(
          # Add gio to PATH so that moving files to the trash works when not using a desktop environment
          --prefix PATH : ${glib.bin}/bin
          --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland --disable-gpu'

        )
      '';
      postFixup = ''
        patchelf \
          --add-needed ${libglvnd}/lib/libGLESv2.so.2 \
          --add-needed ${libglvnd}/lib/libGL.so.1 \
          --add-needed ${libglvnd}/lib/libEGL.so.1\
          $out/lib/vscode/code-insiders
      '';
      version = "latest";
    });
}
