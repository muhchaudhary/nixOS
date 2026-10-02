# MoonDeck Buddy, the companion server for the MoonDeck SteamDeck plugin.
# pkgs.moondeck-buddy comes from the moondeck-buddy overlay (see overlays/).
{pkgs, ...}: {
  home.packages = [pkgs.moondeck-buddy];

  # Runs the tray/REST-server component (MoonDeckBuddy binary, the AppImage's
  # default) so the SteamDeck can query/control this PC over the network.
  # The MoonDeckStream binary is invoked separately, by Sunshine, per-stream.
  systemd.user.services.moondeck-buddy = {
    Unit = {
      Description = "MoonDeck Buddy";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.moondeck-buddy}/bin/moondeck-buddy";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
