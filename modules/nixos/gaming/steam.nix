{
  pkgs,
  inputs,
  ...
}: {
  # Provides programs.steam.platformOptimizations.
  imports = [inputs.nix-gaming.result.nixosModules.platformOptimizations];

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  users.users.muhammad.extraGroups = ["gamemode" "plugdev"];
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
    protontricks.enable = true;
    platformOptimizations.enable = true;
  };
}
