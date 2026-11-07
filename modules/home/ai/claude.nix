# Claude Code (~/.claude stays unmanaged), plus claude-monitor for usage tracking and chafa
# as its terminal image fallback when no native image protocol is available (e.g. over SSH).
{
  pkgs,
  inputs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  };

  home.packages = [pkgs.claude-monitor pkgs.chafa];
}
