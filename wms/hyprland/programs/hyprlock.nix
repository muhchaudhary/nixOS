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
    package = pkgs.hyprlock;
    backgrounds = [
      {
        path = "screenshot";
        blur_passes = 3;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      }
    ];
    input-fields = [
      {
        size = {
          width = 250;
          height = 60;
        };
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        font_color = "rgb(200, 200, 200)";
        fade_on_empty = false;

        placeholder_text = "";
        halign = "center";
        valign = "center";
      }
    ];
    labels = [
      {
        text = "Hi there, $USER";
        font_size = 50;
        font_family = "Sans";
        position = {
          x = 0;
          y = 80;
        };
      }
      {
        text = "cmd[update:1000] date '+%I:%M %p'";
        font_size = 150;
        font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
        color = "rgba(255, 255, 255, 0.6)";
        position = {
          x = 0;
          y = 200;
        };
      }
    ];
  };
}
