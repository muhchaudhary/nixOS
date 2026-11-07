# Download from muhammadDesktop's binary cache (binary-cache.nix) over the tailnet.
# Build everything there first (`nilla build allSystems` on the desktop), then
# `nilla os switch` here fetches the results instead of building them. When the
# desktop is asleep or off, Nix gives up on it after connect-timeout and uses the
# other caches (or builds locally).
{...}: {
  nix.settings = {
    substituters = ["http://muhammaddesktop:5000"];
    trusted-public-keys = ["muhammadDesktop-1:+xXzCneO+JuJRy6bLTs3uxsGNJ0P5zYj5Lz5tRxxKNY="];
    connect-timeout = 5;
    fallback = true;
  };
}
