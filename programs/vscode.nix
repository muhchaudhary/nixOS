{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
  ];

  programs.vscode = {
    enable = true;
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
