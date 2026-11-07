# Pi coding agent (~/.pi stays unmanaged).
{
  pkgs,
  inputs,
  ...
}: {
  programs.pi-coding-agent = {
    enable = true;
    package = inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.pi;
  };
}
