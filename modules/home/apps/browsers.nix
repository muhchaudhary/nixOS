{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    firefox
    inputs.zen-browser.result.packages.${pkgs.stdenv.hostPlatform.system}.default
    chromium
  ];
}
