{
  config,
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hyprspace.packages.${pkgs.system}.Hyprspace
    ];
    settings = {
      plugin.overview = {
        hideBackgroundLayers = true;
        panelHeight = 150;
        workspaceBorderSize = 10;
        workspaceActiveBorder = "rgb(88c0d0)";
        panelColor = "rgba(00000000)";
      };
    };
  };
}
