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
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/insider/ae59067554575afaba07640320a26435c8e05175/code-insider-x64-1712060988.tar.gz";
          sha256 = "1j65xpb1k35qm8jcg9wcmri7jay1v037dz8iqbf23bb37r9d2h6k";
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
