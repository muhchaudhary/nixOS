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
      }
    ];
  };
}
