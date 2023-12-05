{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # vscode extensions stuff
    rnix-lsp
    alejandra
  ];

  programs.vscode = {
    enable = true;
    package = with pkgs;
      (pkgs.vscode.override {})
      .overrideAttrs
      (prevAttrs: {
        preFixup = ''
          gappsWrapperArgs+=(
            # Add gio to PATH so that moving files to the trash works when not using a desktop environment
            --prefix PATH : ${glib.bin}/bin
            --add-flags '--disable-gpu-sandbox'
          )
        '';
        postFixup = ''
          patchelf \
            --add-needed ${libglvnd}/lib/libGLESv2.so.2 \
            --add-needed ${libglvnd}/lib/libGL.so.1 \
            --add-needed ${libglvnd}/lib/libEGL.so.1\
            $out/lib/vscode/code
        '';
      });
  };
  extensions = with pkgs;
  with vscode-extensions;
    [
      kamadorueda.alejandra
      bbenoist.nix
      esbenp.prettier-vscode
      ms-python.python
      ms-python.vscode-pylance
      timonwong.shellcheck
      foxundermoon.shell-format
      eamodio.gitlens
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "popping-and-locking-vscode-black";
        publisher = "philsinatra";
        version = "1.1.7";
        sha256 = "1234";
      }
      {
        name = "showtime";
        publisher = "AlexFromXD";
        version = "0.0.3";
        sha256 = "1234";
      }
    ];
}
