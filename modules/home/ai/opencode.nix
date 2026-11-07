# OpenCode, set up in ~/.config/opencode/opencode.json for the llama-swap server on
# muhammadDesktop (~/Documents/LLMs), reached over the tailnet.
{
  pkgs,
  inputs,
  ...
}: let
  # llm-agents' `opencode` is still the 1.x line; the 2.x line is `opencode2`, installed
  # under that name to coexist with it. Expose it as plain `opencode` (T3 Code calls that).
  opencode2 = inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
in {
  programs.opencode = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "opencode-${opencode2.version}";
      inherit (opencode2) version;
      paths = [opencode2];
      postBuild = "ln -s opencode2 $out/bin/opencode";
      meta = opencode2.meta // {mainProgram = "opencode";};
    };
  };
}
