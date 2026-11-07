# T3 Code (t3.codes), a GUI for coding agents. Its wrapper puts the agent CLIs it drives on
# its PATH: the same Claude Code and OpenCode as the CLIs (so it imports their modules), not
# the Codex/Cursor/Grok it bundles by default. ~/.t3/userdata stays writable.
{
  config,
  pkgs,
  inputs,
  ...
}: let
  t3code = inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.t3code.override {
    providerPackages = [
      config.programs.claude-code.package
      config.programs.opencode.package
    ];
  };
in {
  imports = [
    ./claude.nix
    ./opencode.nix
  ];

  programs.t3code = {
    enable = true;
    package = t3code; # the `t3` CLI/server
  };

  # The Electron app (`t3code-desktop`) is a separate output.
  home.packages = [t3code.desktop];
}
