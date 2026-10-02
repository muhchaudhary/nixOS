{pkgs, ...}: {
  home.packages = with pkgs; [
    inkscape
    blender_4_5
    kicad-small
    godot_4
  ];
}
