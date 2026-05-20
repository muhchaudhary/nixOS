{
  lib,
  pkgs,
  inputs,
  namespace,
  home,
  target,
  format,
  virtual,
  host,
  config,
  ...
}:
with lib;
with lib.internal; {
  # CLI tools (git, fish, fzf, fastfetch, infra) come via the shared muhammad/ home.
  # No desktop, apps, or themes needed on a headless server.
}
