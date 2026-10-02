{config, ...}: {
  home.username = "muhammad";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
    extraConfig = {
      SCREENSHOTS = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
