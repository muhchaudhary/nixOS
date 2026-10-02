{pkgs, ...}: {
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  # Enable scanning — epsonscan2 covers modern Epson USB devices (ET-4550, etc.)
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan pkgs.epsonscan2];
  };

  # Add your user account to the scanner and lp groups
  users.users.muhammad.extraGroups = ["scanner" "lp"];
}
