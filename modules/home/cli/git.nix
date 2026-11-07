{pkgs, ...}: {
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    package = pkgs.gitFull;
    signing.format = null;

    settings = {
      user = {
        name = "muhchaudhary";
        email = "61593188+muhchaudhary@users.noreply.github.com";
      };
      color.ui = "auto";
      push = {
        autoSetupRemote = true;
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
    };
  };
}
