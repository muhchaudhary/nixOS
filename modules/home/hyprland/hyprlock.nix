# Lock screen: minimal, after SDDM's where-is-my-sddm-theme (black, nothing but
# the password) with Style-7's stacked clock from MrVivekRajan/Hyprlock-Styles
# (StretchPro, from modules/nixos/desktop/fonts.nix). The input field draws `*`s
# and a blinking caret (overlays/hyprlock.nix) in the clock's accent colour,
# re-hued on every keystroke, red after a failed attempt.
#
# The widgets come from `hyprlockWidgets {monitor, scale}` (a module arg), so a
# host can lay them out per monitor: hosts/muhammadDesktop/hyprland.nix
# replaces the default all-monitors set with one per output, the TV's doubled.
{lib, ...}: let
  accent = "rgb(147, 196, 255)";

  hyprlockWidgets = {
    monitor ? "",
    scale ? 1,
  }: let
    px = n: toString (n * scale);
    at = x: y: "${px x}, ${px y}";
  in {
    label = [
      # Hour, with the minute below it, shifted right.
      {
        inherit monitor;
        text = ''cmd[update:1000] echo "$(date +"%I")"'';
        color = "rgb(255, 255, 255)";
        font_size = 125 * scale;
        font_family = "Stretch Pro";
        position = at (-80) 190;
        halign = "center";
        valign = "center";
      }
      {
        inherit monitor;
        text = ''cmd[update:1000] echo "$(date +"%M")"'';
        color = accent;
        font_size = 125 * scale;
        font_family = "Stretch Pro";
        position = at 0 70;
        halign = "center";
        valign = "center";
      }
      {
        inherit monitor;
        text = ''cmd[update:60000] echo "$(date +"%d %B, %a.")"'';
        color = "rgba(255, 255, 255, 0.6)";
        font_size = 18 * scale;
        font_family = "JetBrains Mono";
        position = at 20 (-8);
        halign = "center";
        valign = "center";
      }
    ];

    input-field = [
      {
        inherit monitor;
        size = at 600 70;
        outline_thickness = 0;
        dots_text_format = "*";
        dots_size = 0.5;
        dots_spacing = 0.25;
        dots_center = true;
        caret = true;
        hide_input_base_color = accent;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(0, 0, 0, 0)";
        # Borderless, these would fill the whole box; swapped, they colour the
        # asterisks (and caret) instead: dimmed while checking, amber with caps
        # lock on, red after a failure.
        swap_font_color = true;
        check_color = "rgba(255, 255, 255, 0.4)";
        fail_color = "rgb(239, 68, 68)";
        capslock_color = "rgb(245, 158, 11)";
        font_color = "rgb(255, 255, 255)";
        font_family = "JetBrains Mono";
        fade_on_empty = false;
        placeholder_text = "";
        fail_text = "";
        hide_input = false;
        position = at 0 (-160);
        halign = "center";
        valign = "center";
      }
    ];
  };
in {
  _module.args.hyprlockWidgets = hyprlockWidgets;

  programs.hyprlock = {
    enable = true;
    settings =
      {
        general.hide_cursor = true;
        animations.enabled = false;
        background = [
          {
            monitor = "";
            color = "rgb(0, 0, 0)";
          }
        ];
      }
      // lib.mapAttrs (_: lib.mkDefault) (hyprlockWidgets {});
  };
}
