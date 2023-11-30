{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "muhammadahmchaudhary@gmail.com";
    userEmail = "muhchaudhary";
  };
}