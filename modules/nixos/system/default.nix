# Umbrella for the baseline desktop system: boot, locale, and the common
# hardware stack. Import individual pieces directly (e.g. a headless host that
# only wants boot + locale + network) instead of this barrel.
{...}: {
  imports = [
    ./boot.nix
    ./locale.nix
    ../hardware/sound.nix
    ../hardware/network.nix
    ../hardware/bluetooth.nix
    ../hardware/printer.nix
  ];
}
