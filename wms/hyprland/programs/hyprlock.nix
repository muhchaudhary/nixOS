{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
  ];

  programs.hyprlock = {
    enable = true;

    general = {
      grace = 10;
    };
    backgrounds = [
      {
        path = "";
        color = "rgba(0, 0, 0, 0.5)";
        blur_passes = 4;
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }
    ];
  };
}
