{pkgs, ...}: {
  home.packages = with pkgs; [
    git-credential-manager
  ];
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
  # programs.git-credential-oauth.enable = true;

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
      credential.credentialStore = "secretservice";
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
