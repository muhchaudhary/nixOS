{...}: {
  programs.starship = {
    enable = true;
  };
  programs.kitty = {
    enable = true;

    shellIntegration.enableFishIntegration = true;
    font = {
      name = "Fira Code";
      size = 12;
    };
    settings = {
      shell = "fish";
      # kitty also remembers the maximized state, so one maximized window made
      # every new one open maximized; sizing is the compositor's job anyway
      remember_window_size = "no";
    };
    extraConfig = "
      background_opacity 0.8
      confirm_os_window_close 0
  ";
  };
}
