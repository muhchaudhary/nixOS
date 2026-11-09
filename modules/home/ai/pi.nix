# Pi coding agent, set up in ~/.pi/agent/models.json (+ defaultProvider/defaultModel in
# settings.json) for the llama-swap server on muhammadDesktop. ~/.pi stays unmanaged.
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
