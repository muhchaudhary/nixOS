# hyprlock with a text caret: adds an input-field `caret` option that draws a blinking
# bar after the last dot, recoloured to a random hue (of hide_input_base_color)
# on every keystroke, fail_color after a failed attempt (where-is-my-sddm-theme
# style). Used by the lock screen in modules/home/hyprland. If a pin update
# makes the patch fail to apply, refresh it against the new hyprlock source.
final: prev: {
  hyprlock = prev.hyprlock.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./hyprlock-caret.patch];
  });
}
