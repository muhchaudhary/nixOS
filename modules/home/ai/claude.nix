# Claude Code (~/.claude stays unmanaged), plus claude-monitor for usage tracking.
{
  pkgs,
  inputs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  };

  home.packages = [pkgs.claude-monitor];
}
