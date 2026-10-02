{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [droidcam-obs];
  };

  home.packages = [pkgs.droidcam pkgs.moonlight-qt];
}
