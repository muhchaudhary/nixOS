{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    ruff
  ];

  programs.vscode = {
    enable = true;
    package = with pkgs;
      (vscode.override {isInsiders = true;})
      .overrideAttrs
      (prevAttrs: {
        src = builtins.fetchTarball {
          # run curl -I https://update.code.visualstudio.com/latest/linux-x64/insider to get latest url
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/ed6c6d3f28fa4cb66f6d73918365e41fb81db14c/code-insider-x64-1712555430.tar.gz";
          sha256 = "sha256:1jjhzfk83w35gz4c2spnycy9alpfawn9a6l80n2c7hlzshzs8fv7";
          # sha256 = lib.fakeSha256;
        };
        version = "latest";
      });
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
          sha256 = "sha256-D05Bqoahrd+r57/GhbDbBeaWmZ4vTByK+P8UmyYNVR0=";
        }
        {
          name = "showtime";
          publisher = "AlexFromXD";
          version = "0.0.3";
          sha256 = "sha256-MJ24fs0qzdWLi6anaI60AufwzlQ2Sx5NFsHb6NJ/wX8=";
        }
      ];
  };
}
